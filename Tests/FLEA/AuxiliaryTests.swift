import XCTest

@testable import FLEA

public class AuxiliaryTests : XCTestCase {
  static var allTests : [(String, (AuxiliaryTests) -> () throws -> Void)] {
    return [
      ("testUppercased", testUppercased)
    ]
  }

  func testUppercased() {
    let u = "Flea"
    let l = "flea"

    XCTAssertTrue(u.isUppercased(at:u.startIndex),nok)
    XCTAssertFalse(l.isUppercased(at:l.startIndex),nok)



  }


}
