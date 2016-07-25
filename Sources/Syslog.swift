/// Wrapper for [syslog](https://en.wikipedia.org/wiki/Syslog)
#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

struct Syslog {
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
    private var priority : Int32 {
      switch self {
        case emergency: return LOG_EMERG
        case alert: return LOG_ALERT
        case critical: return LOG_CRIT
        case error: return LOG_ERR
        case warning: return LOG_WARNING
        case notice: return LOG_NOTICE
        case info: return LOG_INFO
        case debug: return LOG_DEBUG
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
    private var option: Int32 {
      switch self {
        case console: return LOG_CONS
        case immediately: return LOG_NDELAY
        case nowait:return LOG_NOWAIT
        case delayed:return LOG_ODELAY
        case perror:return LOG_PERROR
        case pid:return LOG_PID
      }
    }
  }

  static func openLog(ident:String, options:Syslog.Option..., facility:Int32 = LOG_USER) {
    let option = options.reduce(0) { $0 | $1.option }
    openlog(ident, option, facility);
  }

  // static func openLog(ident:String, options:[Syslog.Option], facility:Int32 = LOG_USER) {
  //   let option = options.reduce(0) { $0 | $1.option }
  //   openlog(ident, option, facility);
  // }

  static func closeLog() {
    closelog()
  }

  private static var available = Set<Priority>()

  private static func setLogMask() -> Int32 {
    let priority = Syslog.available.reduce(0) { $0 + (1 << $1.priority)}
    return setlogmask(priority)
  }

  static func setLogMask(upTo:Syslog.Priority) -> Int32 {
    Syslog.available = Set(
      Syslog.Priority.all.filter { $0.priority <= upTo.priority }
    )
    return setLogMask()
  }

  static func setLogMask(priorities:Syslog.Priority...) -> Int32 {
    Syslog.available = Set(priorities)
    return setLogMask()
  }

  /// void syslog(int priority, const char *format, ...);
  private static func syslog(
      priority : Int32,
      message : String,
      args : CVarArg...) {
        withVaList(args) {
          vsyslog(priority, message, $0)
        }
    }

  // void vsyslog(int priority, const char *format, va_list ap);
  private static func sysLog(
    priority : Priority,
    args : CVarArg...,
    message : () -> String
  ) {
      withVaList(args) {
        vsyslog(priority.priority, message(), $0)
      }
  }

  private static func loggable(_ priority:Priority, _ file:String, _ function:String, _ line:Int) -> Bool {
    guard Syslog.available.contains(priority) else { return false }

    // TODO: register and unregister files, functions, lines for logging

    return true
  }

  private static func log(
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
        args: errcode, line, column) {
          "\(file.lastPathComponent)[%d:%d].\(function) '%m'(%d) \(message())"
        }
    }
    else {
      Syslog.sysLog(priority:priority,
        args: line, column) {
          "\(file.lastPathComponent)[%d:%d].\(function) \(message())"
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
        "{\(p)} \(message())"
      }
    }
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
    log (.info, errcode:errcode, file:file, function:function, line:line, column:column, message:message)
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
