import XCTest

@testable import FLEA

public class AuxiliaryTests : XCTestCase {
  static var allTests : [(String, (AuxiliaryTests) -> () throws -> Void)] {
    return [
      ("testUppercased", testUppercased),
      ("testIds",testIds)
    ]
  }

  func testUppercased() {
    let u = "Flea"
    let l = "flea"

    XCTAssertTrue(u.isUppercased(at:u.startIndex),nok)
    XCTAssertFalse(l.isUppercased(at:l.startIndex),nok)
  }

  func testIds() {
    let $ = "$"
    XCTAssertEqual($,"$")
    let a$ = "a$"
    XCTAssertEqual(a$,"a$")
    // let $a = "$a" // error: expected numeric value following '$'
    // XCTAssertEqual($a,"$a")
    let a$a = "a$a"
    XCTAssertEqual(a$a,"a$a")

    let € = "?"
    XCTAssertEqual(€,"?")
    let a€ = "?"
    XCTAssertEqual(a€,"?")
    let €a = "?"
    XCTAssertEqual(€a,"?")
    let a€a = "?"
    XCTAssertEqual(a€a,"?")
  }
}
