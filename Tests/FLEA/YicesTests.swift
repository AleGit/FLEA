import XCTest

@testable import FLEA

public class YicesTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (YicesTests) -> () throws -> Void)]  {
    return [
      ("testPUZ001c1", testPUZ001c1)
    ]
  }

  func testPUZ001c1() {
    let problem = "PUZ001-1"
    guard let path = problem.p else {
      XCTFail("\(nok) '\(problem)' not found.")
      return 
    }

  }
}
