#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

import XCTest

@testable import FLEA

public class SyslogTests: FleaTestCase {
  static var allTests: [(String, (SyslogTests) -> () throws -> Void)] {
    return [
    ("testSyslog", testSyslog),
    ("testConfiguration", testConfiguration)
    ]
  }

  // func syslog(priority : Int32, _ message : String, _ args : CVarArg...) {
  //   withVaList(args) { vsyslog(priority, message, $0) }
  // }

  /// [syslog](https://en.wikipedia.org/wiki/Syslog) wrapper demo.
  /// Messages should appear near the output of the test,
  public override func setUp() {
    super.setUp()
    // Put setUp code here. This method is called before the invocation of each test method in the class.
    // Syslog.openLog(ident:"ABC", options:.console,.pid,.perror)
    let _ = Syslog.setLogMask(upTo:.debug)
  }

  public override func tearDown() {

    // Syslog.closeLog()
    // Put tearDown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }


  func testSyslog() {

    #if os(OSX)
    let ident = "at.maringele.flea.xctest"
    #elseif os(Linux)
    let ident = "X" // up to 6 charactes on Linux
    #endif

    XCTAssertEqual(Syslog.configured, Syslog.Priority.all, nok)

    // void openlog(const char *ident, int logopt, int facility);
    Syslog.openLog(options:.console,.pid,.perror)
    defer {
      //  void closelog(void);
      Syslog.closeLog();
    }

    // int setlogmask(int maskpri);
    let logmask0 = Syslog.setLogMask(priorities: .debug, .error)
    XCTAssertEqual(Int32(255),logmask0)

    Syslog.debug { "MUST APPEAR"}
    Syslog.warning { "MUST NOT APPEAR "}

    let logmask1 = Syslog.clearLogMask()
    XCTAssertEqual(Int32(128+8),logmask1)
    Syslog.multiple { "THIS MULTIPLE MUST NOT APPEAR"}

    // create new error and log it
    let newerror = open("/fictitious_file", O_RDONLY, 0); // sets errno to ENOENT

    let logmask2 = Syslog.setLogMask(upTo:.debug)
    XCTAssertEqual(Int32(128+8),logmask2)

    Syslog.debug(errcode: newerror) { " File not found "}

    let oldmask = Syslog.setLogMask(priorities:.debug, .warning, .debug)
    XCTAssertEqual(255,oldmask)

    Syslog.multiple(errcode: newerror) { "This was a silly test." }

    let _ = Syslog.setLogMask(upTo:.debug)
  }

  func testConfiguration() {
    let path = "Configs/default.logging"

    guard let allLines = path.lines(), allLines.count > 15 else {
      XCTFail()
      return
    }

    guard let lines = path.lines(predicate:{
       !($0.hasPrefix("#") || $0.isEmpty)
    }), lines.count == 6 else {
      XCTFail()
      return
    }

    XCTAssertTrue(allLines.count > lines.count)




  }
}
