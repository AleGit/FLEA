import XCTest

@testable import FLEA

public class DemoTests : FleaTestCase {
  static var allTests : [(String, (DemoTests) -> () throws -> Void)] {
    return [
      ("testDemo", testDemo),
      ("testProblem", testProblem)
    ]
  }

  func testDemo() {
    XCTAssertNil(Demo.demo())
  }

  func testProblem() {
    Demo.show = false
    XCTAssertEqual(12,Demo.Problem.parseCnf(),nok)
    XCTAssertEqual(14,Demo.Problem.parseFof(),nok)
    XCTAssertEqual(0,Demo.Problem.broken(),nok)

    // too expensive in debug mode
    // XCTAssertEqual(12,Demo.Problem.simpleNode(show:false),nok)
    // XCTAssertEqual(12,Demo.Problem.sharingNode(show:false),nok)
    // XCTAssertEqual(12,Demo.Problem.smartNode(show:false),nok)
    // XCTAssertEqual(12,Demo.Problem.kinNode(show:false),nok)
  }

  func _testSimple() {

    XCTAssertEqual(2332428,Demo.Problem.simpleNode(),nok)
    print(ok,#function)
  } 

  func _testSharing() {

    XCTAssertEqual(2332428,Demo.Problem.sharingNode(),nok)
    print(ok,#function)

  }
}
