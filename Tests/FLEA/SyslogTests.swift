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

  /// [syslog](https://en.wikipedia.org/wiki/Syslog) wrapper demo.
  /// Messages should appear near the output of the test,
  func testSyslog() {

    #if os(OSX)
    let ident = "at.maringele.flea.xctest"
    #elseif os(Linux)
    let ident = "" // up to 6 charactes on Linux
    #endif

    XCTAssertEqual(Syslog.configured, Syslog.Priority.all, nok)

    // void openlog(const char *ident, int logopt, int facility);
    Syslog.openLog(ident:ident, options:.console,.pid,.perror)
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
  }

  func testConfiguration() {
    let path = "Config/sample.default"
    guard let content = try? String(contentsOfFile:path) else {
      XCTFail("\(nok) config file '\(path)' not found.")
      return
    }
    print(content)

    let ws = CharacterSet.whitespaces

    let entries = content.lines.filter {
      !($0.hasPrefix("#") || $0.trimmingCharacters(in:ws).isEmpty)
     }
     print(entries)



  }
}
