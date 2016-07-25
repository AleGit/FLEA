#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import XCTest

@testable import FLEA

public class SyslogTests : XCTestCase {
  static var allTests : [(String, (SyslogTests) -> () throws -> Void)] {
    return [
    ("testSyslog", testSyslog),
    ]
  }

  // func syslog(priority : Int32, _ message : String, _ args : CVarArg...) {
  //   withVaList(args) { vsyslog(priority, message, $0) }
  // }

  /// not a real test, just a demo how to use syslog.
  /// messages should appear near the output of the test
  func testSyslog() {
    print("\(#function) started")

    #if os(OSX)
    let ident = "at.maringele.flea.xctest"
    #elseif os(Linux)
    let ident = "" // up to 6 charactes on Linux
    #endif

    // let options = [Syslog.Option.console,.pid,.perror] // (LOG_CONS|LOG_PERROR|LOG_PID)

    /// void openlog(const char *ident, int option, int facility);
    Syslog.openLog(ident:ident, options:.console,.pid,.perror)
    let _ = Syslog.setLogMask(priorities: .debug, .emergency)

    // log last error
    // Syslog.debug(message:"Previous error:", errcode:errno)

    // create new error and log it
    let _ = open("/fictitious_file", O_RDONLY, 0); // sets errno to ENOENT

    let newerror = Syslog.setLogMask(priorities:.debug, .critical, .debug)

    Syslog.debug { "üüüüüüüüüüüüüüüüüüüüüüüüüühhhhhhhhhhhhhhhhhhhhhiiiiiii"}
    Syslog.warning { "ääääääääähhhhhhhhhhhhhhhhhhiiiiiii"}
    Syslog.debug(errcode: newerror) { " File not found "}

    // log it again
    Syslog.multiple(errcode: newerror) { "This is a silly test." }

    let _ = Syslog.setLogMask(upTo:.debug)
    Syslog.multiple(errcode: newerror) { "This was a silly test." }

    //  void closelog(void);
    Syslog.closeLog();

    print("\(#function) finished")}
}
