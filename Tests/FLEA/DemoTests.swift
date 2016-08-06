import XCTest

@testable import FLEA

public class DemoTests : XCTestCase {
  static var allTests : [(String, (DemoTests) -> () throws -> Void)] {
    return [
      ("testDescription", testDemo)
    ]
  }

  func testDemo() {
    XCTAssertNil(Demo.demo())
  }

  func testProblem() {
    Demo.show = false
    XCTAssertEqual(12,Demo.Problem.puz001cnf(),nok)
    XCTAssertEqual(14,Demo.Problem.puz001fof(),nok)
    XCTAssertEqual(0,Demo.Problem.broken(),nok)

    // too expensive in debug mode
    // XCTAssertEqual(12,Demo.Problem.simpleNode(show:false),nok)
    // XCTAssertEqual(12,Demo.Problem.sharingNode(show:false),nok)
    // XCTAssertEqual(12,Demo.Problem.smartNode(show:false),nok)
    // XCTAssertEqual(12,Demo.Problem.kinNode(show:false),nok)
  }
}
