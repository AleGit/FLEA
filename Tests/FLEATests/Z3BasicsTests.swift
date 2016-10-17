import XCTest

import Foundation
@testable import FLEA

public class Z3BasicsTests: FleaTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (Z3BasicsTests) -> () throws -> Void)] {
    return [
      ("testVersionString", testVersionString),

    ]
  }

  func testVersionString() {
    let expected = "4.4.2.1"
    let versionString = Z3Basics.versionString
    XCTAssertTrue(versionString.hasPrefix("4."), nok)
    Syslog.debug(condition: versionString != expected ) {
      "\(nok) actual z3 version is \(versionString) is not \(expected)"
    }
    if expected == versionString {
      print(ok, "Z3 version string matches exactly.")
    }
  }

  func testVersion() {
    XCTAssertEqual(4 as UInt32, Z3Basics.version[0])
  }
}