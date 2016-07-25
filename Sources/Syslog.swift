/// Wrapper for [syslog](https://en.wikipedia.org/wiki/Syslog)
#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif


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

  static func setLogMask(priorities:Syslog.Priority...) -> Int32 {
    let raws = priorities.map { $0.priority }
    let priority = Set(raws).reduce(0) { $0 + (1 << $1) }
    let oldPriority = setlogmask(priority)

    if let minimal = raws.min() {
      Syslog.sysLog(priority:minimal,message:"setlogmask(%d) -> %d",args:priority, oldPriority)
    }

    return oldPriority


  }
  private static func sysLog(
      priority : Int32,
      message : String,
      args : CVarArg...) {
        withVaList(args) {
          vsyslog(priority, message, $0)
        }
    }
  // void syslog(int priority, const char *format, ...);
  // void vsyslog(int priority, const char *format, va_list ap);
  static func sysLog(
    priority : Priority,
    message : String,
    args : CVarArg...) {
      withVaList(args) {
        vsyslog(priority.priority, message, $0)
      }
  }

  static func debug(
    message: String,
    errno : Int32 = 0,
    file : String = #file,
    function : String = #function,
    line : Int = #line,
    column : Int = #column
  ) {
    if errno != 0 {
      Syslog.sysLog(priority:.debug,
        message:"\(message) '%m' (%d)\n'\(file)'.\(function)[\(line):\(column)]",
        args:errno)
    }


  }





}
