import XCTest

public class SyslogTests : XCTestCase {
  static var allTests : [(String, (SyslogTests) -> () throws -> Void)] {
    return [
    ("testSyslog", testSyslog),
    ]
  }

  func syslog(priority : Int32, _ message : String, _ args : CVarArg...) {
    withVaList(args) { vsyslog(priority, message, $0) }
  }

  func testSyslog() {
    let _ = open("/fictitious_file", O_RDONLY, 0); // sets errno to ENOENT
    openlog("FleaTestSuite", (LOG_CONS|LOG_PERROR|LOG_PID), LOG_DAEMON);
    syslog(priority:LOG_EMERG, "This is a silly test: Error %m: %d", 42, 31);
    closelog();

    XCTFail(nok)



  }
}
