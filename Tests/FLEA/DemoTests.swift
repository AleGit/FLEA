import XCTest

import FLEA

public class DemoTests : XCTestCase {
  static var allTests : [(String, (DemoTests) -> () throws -> Void)] {
    return [
      ("testDescription", testDemo)
    ]
  }

  func testDemo() {
    XCTAssertNil(Demo.demo())
  }
}
