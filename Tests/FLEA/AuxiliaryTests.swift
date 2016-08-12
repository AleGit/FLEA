import XCTest

@testable import FLEA

public class AuxiliaryTests : XCTestCase {
  static var allTests : [(String, (AuxiliaryTests) -> () throws -> Void)] {
    return [
      ("testDecomposing", testDecomposing),
      ("testAllOneCount", testAllOneCount),
      ("testUppercased", testUppercased),
      ("testStringContains", testStringContains),
      ("testIds",testIds)
    ]
  }

  func testDecomposing() {
    let array = [11,12,13]
    guard let (h1,t1) = array.decomposing else {
      XCTFail(nok)
      return
    }
    XCTAssertEqual(11,h1,nok)
    guard let (h2,t2) = t1.decomposing else {
        XCTFail(nok)
        return
    }
    XCTAssertEqual(12,h2,nok)

    guard let (h3,t3) = t2.decomposing else {
        XCTFail(nok)
        return
    }
    XCTAssertEqual(13,h3,nok)

    XCTAssertNil(t3.decomposing,nok)
  }

  func testAllOneCount() {
    let array = [2,3,5,7,11,13]
    XCTAssertFalse(array.all { $0 % 2 == 0},nok)
    XCTAssertTrue(array.one { $0 % 2 == 0},nok)

    XCTAssertTrue(array.all { $0 > 1},nok)
    XCTAssertFalse(array.one { $0 < 1},nok)

    XCTAssertEqual(1, array.count { $0 % 2 == 0},nok)
    XCTAssertEqual(array.count,array.count { $0 > 1},nok)
    XCTAssertEqual(0, array.count { $0 < 1 },nok)
  }

  func testUppercased() {
    let u = "Flea"
    let l = "flea"

    XCTAssertTrue(u.isUppercased(at:u.startIndex),nok)
    XCTAssertFalse(l.isUppercased(at:l.startIndex),nok)
  }

  func testStringContains() {
    let string = "Héllo, Wörld!"

    XCTAssertTrue(string.containsAll ([String]()), nok)
    XCTAssertFalse(string.containsOne ([String]()), nok)

    XCTAssertTrue(string.containsAll(string.characters.map{String($0)}), nok)
    XCTAssertTrue(string.containsOne(string.characters.map{String($0)}), nok)

    XCTAssertTrue(string.containsOne (["x", "ä", "é"]),nok)
    XCTAssertFalse(string.containsAll (["x", "ä", "é"]),nok)
    XCTAssertFalse(string.containsOne (["x", "ä", "?"]),nok)
    XCTAssertTrue(string.containsAll (["o", "ö", "!"]),nok)
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
