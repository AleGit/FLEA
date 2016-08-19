import XCTest
@testable import FLEA

public class AuxiliaryTests : FleaTestCase {
  static var allTests : [(String, (AuxiliaryTests) -> () throws -> Void)] {
    return [
      ("testDecomposing", testDecomposing),
      ("testAllOneCount", testAllOneCount),
      ("testUppercased", testUppercased),
      ("testContains", testContains),
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

    var checks = 0
    XCTAssertFalse(array.all { 
      checks += 1
      return $0 % 2 == 0
    },nok)
    XCTAssertEqual(2, checks,nok)

    checks = 0
    XCTAssertTrue(array.one { 
      checks += 1
      return $0 % 2 == 0
    },nok)
    XCTAssertEqual(1, checks)

    checks = 0
    XCTAssertTrue(array.all { 
      checks += 1
      return $0 > 1
    },nok)
    XCTAssertEqual(array.count, checks)

    checks = 0
    XCTAssertFalse(array.one { 
      checks += 1
      return $0 < 1
    },nok)
    XCTAssertEqual(array.count, checks)

    // count even elements
    XCTAssertEqual(1, array.count { $0 % 2 == 0},nok)

    // count all elements
    XCTAssertEqual(array.count, array.count(),nok)

    // count elements > 4
    XCTAssertEqual(4, array.count { $0 > 4},nok)

    // count elements > 1
    XCTAssertEqual(array.count,array.count { $0 > 1},nok)

    // count elements < 1 
    XCTAssertEqual(0, array.count { $0 < 1 },nok)
  }

  func testUppercased() {
    let u = "Flea"
    let l = "flea"

    XCTAssertTrue(u.isUppercased(at:u.startIndex),nok)
    XCTAssertFalse(l.isUppercased(at:l.startIndex),nok)

    let ü = "ÜbÉr"
    let ä = "älter"

    print(ü,ü.characters.map {$0})

    XCTAssertTrue(ü.isUppercased(at:ü.startIndex),nok)
    XCTAssertFalse(ü.isUppercased(at:ü.index(after:ü.startIndex)))
    XCTAssertTrue(ü.isUppercased(at:ü.index(ü.startIndex, offsetBy:2)))
    XCTAssertFalse(ü.isUppercased(at:ü.index(before:ü.endIndex)))
    
    XCTAssertFalse(ä.isUppercased(at:ä.startIndex),nok)

  }

  func testContains() {
    let string = "Héllo, Wörld!"
    let ε = ""

    // a string contains all characters of an empty collection
    XCTAssertTrue(string.containsAll ([String]()), nok)
    XCTAssertTrue(ε.containsAll ([String]()), nok)

    // a string contains no character of an empty collection
    XCTAssertFalse(string.containsOne ([String]()), nok)
    XCTAssertFalse(ε.containsOne ([String]()), nok)

    // a string contains all of its characters
    XCTAssertTrue(string.containsAll(string.characters.map{String($0)}), nok)
    XCTAssertTrue(ε.containsAll(ε.characters.map{String($0)}), nok)
    
    // a string contains one of its characters
    XCTAssertTrue(string.containsOne(string.characters.map{String($0)}), nok)
    // a empty string contains not one of its characters
    XCTAssertFalse(ε.containsOne(ε.characters.map{String($0)}), nok)

    XCTAssertTrue(string.containsOne (["x", "ä", "é"]),nok)
    XCTAssertFalse(string.containsAll (["x", "ä", "é"]),nok)
    XCTAssertFalse(string.containsOne (["x", "ä", "?"]),nok)
    XCTAssertTrue(string.containsAll (["o", "ö", "!"]),nok)

    XCTAssertFalse(ε.containsOne (["x", "ä", "é"]),nok)
    XCTAssertFalse(ε.containsAll (["x", "ä", "é"]),nok)
    XCTAssertFalse(ε.containsOne (["x", "ä", "?"]),nok)
    XCTAssertFalse(ε.containsAll (["o", "ö", "!"]),nok)
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
