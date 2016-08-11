import XCTest

@testable import FLEA

public class AuxiliaryTests : XCTestCase {
  static var allTests : [(String, (AuxiliaryTests) -> () throws -> Void)] {
    return [
      ("testDecomposing", testDecomposing),
      ("testUppercased", testUppercased),
      ("testIds",testIds)
    ]
  }

  func testDecomposing() {
    let array = [11,12,13]
    print(array)
    guard let (h1,t1) = array.decomposing else {
      XCTFail(nok)
      return
    }
    print(h1,t1)
    guard let (h2,t2) = t1.decomposing else {
        XCTFail(nok)
        return
    }
    print(h2,t2)

    guard let (h3,t3) = t2.decomposing else {
        XCTFail(nok)
        return
    }
    print(h3,t3)

    print(t3.decomposing)
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
