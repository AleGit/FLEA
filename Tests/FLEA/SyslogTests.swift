import XCTest

#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

public class SyslogTests : XCTestCase {
  static var allTests : [(String, (SyslogTests) -> () throws -> Void)] {
    return [
    ("testSyslog", testSyslog),
    ]
  }

  func syslog(priority : Int32, _ message : String, _ args : CVarArg...) {
    withVaList(args) { vsyslog(priority, message, $0) }
  }

  /// not a real test, just a demo how to use syslog.
  /// messages should appear near the output of the test
  func testSyslog() {
    print("\(#function) started")

    openlog("f\(nok)", (LOG_CONS|LOG_PERROR|LOG_PID), LOG_DAEMON);

    // log last error
    syslog(priority:LOG_EMERG, "This is a silly test: Error '%m': %d",#line);

    // create new error and log it
    let _ = open("/fictitious_file", O_RDONLY, 0); // sets errno to ENOENT
    syslog(priority:LOG_EMERG, "This is a silly test: Error '%m': %d:\(#file)", #line);

    // log it again
    syslog(priority:LOG_DEBUG, "This is a silly test: Error '%m': %d", #line);

    closelog();

    print("\(#function) finished")}
}
