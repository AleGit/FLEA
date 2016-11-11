import XCTest

import Foundation
@testable import FLEA

public class Z3BasicsTests: FleaTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (Z3BasicsTests) -> () throws -> Void)] {
    return [
      ("testVersionString", testVersionString),
      ("testVersion", testVersion),

    ]
  }

  func testVersionString() {
    let expected = "4.5.1.0"
    let versionString = Z3Basics.versionString
    XCTAssertTrue(versionString.hasPrefix("4."), nok)
    Syslog.warning(condition: versionString != expected ) {
      "\n\(nok) actual z3 version \(versionString) does not match \(expected)"
    }
    Syslog.info(condition: versionString == expected) {
      "\n\(ok) actual z3 version \(versionString) matches exactly"
    }
  }

  func testVersion() {
    XCTAssertEqual(4 as UInt32, Z3Basics.version[0])
  }
}