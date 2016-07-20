import XCTest

@testable import FLEA

public class SubstitutionTests : XCTestCase {
  static var allTests : [(String, (SubstitutionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func testBasics() {
    XCTAsserTrue(true)

  }
}
