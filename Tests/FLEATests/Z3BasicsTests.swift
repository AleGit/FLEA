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
    XCTAssertEqual("4.4.2.1", Z3Basics.versionString, nok)
  }
}