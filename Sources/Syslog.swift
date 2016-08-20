
#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

/// Static wrapper for [syslog](https://en.wikipedia.org/wiki/Syslog),
/// see [man 3 syslog]http://www.unix.com/man-page/POSIX/3posix/syslog/
struct Syslog {
  fileprivate static var active = false

  enum Priority {
    case emergency
    case alert
    case critical
    case error
    case warning
    case notice
    case info
    case debug

    // LOG_EMERG      system is unusable
    // LOG_ALERT      action must be taken immediately
    // LOG_CRIT       critical conditions
    // LOG_ERR        error conditions
    // LOG_WARNING    warning conditions
    // LOG_NOTICE     normal, but significant, condition
    // LOG_INFO       informational message
    // LOG_DEBUG      debug-level message
    fileprivate var priority : Int32 {
      switch self {
        case .emergency: return LOG_EMERG
        case .alert: return LOG_ALERT
        case .critical: return LOG_CRIT
        case .error: return LOG_ERR
        case .warning: return LOG_WARNING
        case .notice: return LOG_NOTICE
        case .info: return LOG_INFO
        case .debug: return LOG_DEBUG
      }
    }

    fileprivate init?(string:String) {
      switch string {
        case "emergency":
        self = .emergency
        case "alert":
        self = .alert
        case "critical":
        self = .critical
        case "error":
        self = .error
        case "warning":
        self = .warning
        case "notice":
        self = .notice
        case "info":
        self = .info
        case "debug":
        self = .debug
        default:
        return nil

      }
    }

    static var all = [Priority.emergency, Priority.alert, Priority.critical, Priority.error, Priority.warning, Priority.notice, Priority.info, Priority.debug]
  }

  enum Option {
    case console
    case immediately
    case nowait
    case delayed
    case perror
    case pid
    // LOG_CONS       Write directly to system console if there is an error
    //                while sending to system logger.
    //
    // LOG_NDELAY     Open the connection immediately (normally, the
    //                connection is opened when the first message is
    //                logged).
    //
    // LOG_NOWAIT     Don't wait for child processes that may have been
    //                created while logging the message.  (The GNU C library
    //                does not create a child process, so this option has no
    //                effect on Linux.)
    //
    // LOG_ODELAY     The converse of LOG_NDELAY; opening of the connection
    //                is delayed until syslog() is called.  (This is the
    //                default, and need not be specified.)
    //
    // LOG_PERROR     (Not in POSIX.1-2001 or POSIX.1-2008.)  Print to
    //                stderr as well.
    //
    // LOG_PID        Include PID with each message.
    fileprivate var option: Int32 {
      switch self {
        case .console: return LOG_CONS
        case .immediately: return LOG_NDELAY
        case .nowait:return LOG_NOWAIT
        case .delayed:return LOG_ODELAY
        case .perror:return LOG_PERROR
        case .pid:return LOG_PID
      }
    }
  }

  fileprivate static var activePriorities = Syslog.maskedPriorities

// TODO: better implementation
  static let configuration : [String:Priority]? = {
    defer { Syslog.active = true }
    print(#function,#line,"started")
    defer { print(#function,#line,"finished")}
    
    guard 
      let path = URL.loggingConfigurationURL?.path,
      let content = path.content else {
        print("*** syslog configuration not available ***")
      return nil
    }

    let entries = content.lines.filter {
      !($0.hasPrefix("#") || $0.trimmingWhitespace.isEmpty)
     }

     var d = [String:Priority]()

     for entry in entries {
       guard let colonIndex = entry.characters.index(of:(":")) else {
         print("*** ### invalid entry : \(entry) ### ***")
         continue
       }
       let after = entry.characters.index(after:colonIndex)
       let key = String(entry.characters.prefix(upTo:colonIndex)).trimmingWhitespace.pealing
       var value = ""
       var comment = ""
       if let dashIndex = entry.characters.index(of:("#")) {
         value = String(entry.characters[after..<dashIndex]).trimmingWhitespace.pealing
         comment = String(entry.characters.suffix(from:dashIndex)).trimmingWhitespace
       }
       else {
         value = String(entry.characters.suffix(from:after)).trimmingWhitespace.pealing
       }


       guard let p = Priority(string:value) else {
         continue
       }

       d[key] = p




     }

    return d
  }()
}

extension Syslog {
  fileprivate static var maskedPriorities : Set<Priority> {
    let mask = setlogmask(255)

    let _ = setlogmask(mask)
    let array = Priority.all.filter {
      ((1 << $0.priority) | mask) > 0
    }
    return Set(array)
  }

  static var configured : [Priority] {
    return Syslog.activePriorities.sorted { $0.priority < $1.priority }
  }
}

extension Syslog {

  /* void closelog(void); */

  static func closeLog() {
    closelog()
  }

  /* void openlog(const char *ident, int logopt, int facility); */

  static func openLog(ident:String?=nil, options:Syslog.Option..., facility:Int32 = LOG_USER) {
    let option = options.reduce(0) { $0 | $1.option }
    openlog(ident, option, facility);
    // ident == nil => use process name
    // idetn != nil => does not work on Linux
  }

  /* int setlogmask(int maskpri); */

  fileprivate static func setLogMask() -> Int32 {
    let mask = Syslog.activePriorities.reduce(0) { $0 + (1 << $1.priority)}
    return setlogmask(mask)
  }

  static func setLogMask(upTo:Syslog.Priority) -> Int32 {
    Syslog.activePriorities = Set(
      Syslog.Priority.all.filter { $0.priority <= upTo.priority }
    )
    return setLogMask()
  }

  static func setLogMask(priorities:Syslog.Priority...) -> Int32 {
    Syslog.activePriorities = Set(priorities)
    return setLogMask()
  }

  static func clearLogMask() -> Int32 {
    Syslog.activePriorities = Set<Priority>()
    return setLogMask()
  }

  /*  void syslog(int priority, const char *format, ...); */
  /*  void vsyslog(int priority, const char *format, va_list ap); */

  fileprivate static func syslog(
      priority : Int32,
      message : String,
      args : CVarArg...) {
        withVaList(args) {
          vsyslog(priority, message, $0)
        }
    }

  fileprivate static func sysLog(
    priority : Priority,
    args : CVarArg...,
    message : () -> String
  ) {
      withVaList(args) {
        vsyslog(priority.priority, message(), $0)
      }
  }

  private static var maximalLogLevel : Int32 = Syslog.configuration?["+++"]?.priority ?? Priority.error.priority
  private static var minimalLogLevel : Int32 = Syslog.configuration?["---"]?.priority ?? Priority.error.priority
  private static var defaultLogLevel : Int32 = Syslog.configuration?["***"]?.priority ?? Priority.error.priority


  fileprivate static func loggable(_ priority:Priority, _ file:String, _ function:String, _ line:Int) -> Bool {
    guard Syslog.active, 
    Syslog.activePriorities.contains(priority) else { 
      return false 
    }

    // without a configuration or a priority <= minimal log level priority : log it

    guard let configuration = Syslog.configuration   // is a configuration available
    , priority.priority > Syslog.minimalLogLevel     // is the priority > minimal logged priority
    else { return true }

    // configuration and minimal log level < priority

    let fileName = URL(fileURLWithPath:file).lastComponentOrEmpty 
    if fileName.isEmpty {
      print("••• Last path element of \(file) could not be extracted. •••")
    }
    
    if let ps = configuration["\(fileName)/\(function)"] {
      return priority.priority <= ps.priority
    }
    if let ps = configuration["\(fileName)"] {
      return priority.priority <= ps.priority
    }

    return priority.priority <= Syslog.defaultLogLevel
  }

  fileprivate static func log(
    _ priority: Priority,
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    if errcode != 0 {
      Syslog.sysLog(priority:priority,
        args: line, column) {
          #if os(OSX)
          return "\(URL(fileURLWithPath:file).lastComponentOrEmpty)[%d:%d] \(function) '%m' \(message())"
          #elseif os(Linux)
          return "\(loggingTime()) <\(priority)>: \(URL(fileURLWithPath:file).lastComponentOrEmpty)[%d:%d] \(function) '%m' \(message())"
          #endif
        }
    }
    else {
      Syslog.sysLog(priority:priority,
        args: line, column) {
          #if os(OSX)
          return "\(URL(fileURLWithPath:file).lastComponentOrEmpty)[%d:%d] \(function) \(message())"
          #elseif os(Linux)
          return "\(loggingTime()) <\(priority)>: \(URL(fileURLWithPath:file).lastComponentOrEmpty)[%d:%d] \(function) \(message())"
          #endif
        }
    }
  }

  static func multiple (
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    for p in Syslog.Priority.all {
      guard Syslog.loggable(p,file,function,line) else { continue }
      Syslog.log (p, errcode:errcode, file:file, function:function, line:line, column:column) {
        "\(message())"
      }
    }
  }

  static func error(
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    guard Syslog.loggable(.error, file, function, line) else { return }
    log (.error, errcode:errcode, file:file, function:function, line:line, column:column, message:message)
  }

  static func warning(
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    guard Syslog.loggable(.warning, file, function, line) else { return }
    log (.warning, errcode:errcode, file:file, function:function, line:line, column:column, message:message)
  }

  static func notice(
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    guard Syslog.loggable(.notice, file, function, line) else { return }
    log (.notice, errcode:errcode, file:file, function:function, line:line, column:column, message:message)
  }

  static func info(
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    guard Syslog.loggable(.info, file, function, line) else { return }
    log (.info, errcode:errcode, file:file, function:function, line:line, column:column, message:message)
  }

  static func debug(
    errcode : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column,
    message : () -> String
  ) {
    guard Syslog.loggable(.debug, file, function, line) else { return }
    //#if DEBUG
    log (.debug, errcode:errcode, file:file, function:function, line:line, column:column, message:message)
    //#endif
  }
}

extension Syslog {
  struct Tags {
    static var system : () -> String = {
      #if os(OSX)
      return "#OSX"
      #elseif os(Linux)
      return "#Linux"
      #else
      return "#aOS"
      #endif
    }

    static var workaround: () -> String = {
      return "#Workaround"
    }
  }
}
