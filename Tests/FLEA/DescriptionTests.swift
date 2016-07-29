import XCTest

@testable import FLEA

public class DescriptionTests : XCTestCase {
  static var allTests : [(String, (DescriptionTests) -> () throws -> Void)] {
    return [
      ("testDescription", testDescription)
    ]
  }

  func testDescription() {
    XCTAssertEqual("a", Q.a.description)
    XCTAssertEqual("X", Q.X.description)
  }

  func testDebugDescription() {
    XCTAssertEqual("273", Q.a.debugDescription)
    XCTAssertEqual("786", Q.X.debugDescription)
  }
}
