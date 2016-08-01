import XCTest

@testable import FLEA

public class TrieTests : XCTestCase {
  static var allTests : [(String, (TrieTests) -> () throws -> Void)] {
    return [
    ("testTrieStruct", testTrieStruct),
//    ("testTrieClass", testTrieClass)
    ]
  }

  let pathA = [1,4,5,6,7,8]
  let valueA = "A"
  let pathB = [1,4,5,6,1]
  let valueB = "B"

  func testTrieStruct() {
    typealias T = FLEA.TrieStruct

    var mytrie = T<Int,String>()
    var mytrie2 = T(with:valueA,at:pathA)

    XCTAssertTrue(mytrie.isEmpty,nok)
    mytrie.insert(valueA, at:pathA)
    XCTAssertEqual(mytrie,mytrie2,nok)

    mytrie.insert(valueB, at:pathB)
    mytrie2.insert(valueB,at:pathB)
    XCTAssertEqual(mytrie,mytrie2,nok)

    // delete values from wrong path
    XCTAssertNil(mytrie.delete(valueA, at:pathB),nok)
    XCTAssertNil(mytrie.delete(valueB, at:pathA),nok)

    // delete value a from path a
    XCTAssertEqual(valueA, mytrie.delete(valueA, at:pathA),nok)
    XCTAssertFalse(mytrie.isEmpty,nok)
    //

    // delete value b from path b
    XCTAssertEqual(valueB, mytrie.delete(valueB,at:pathB),nok)
    XCTAssertTrue(mytrie.isEmpty,nok)
  }

  func testTrieClass() {
    typealias T = FLEA.TrieClass

    var mytrie = T<Int,String>()
    var mytrie2 = T(with:valueA,at:pathA)

    XCTAssertTrue(mytrie.isEmpty,nok)
    mytrie.insert(valueA, at:pathA)
    XCTAssertEqual(mytrie,mytrie2,nok)

    mytrie.insert(valueB, at:pathB)
    mytrie2.insert(valueB,at:pathB)
    XCTAssertEqual(mytrie,mytrie2,nok)

    // delete values from wrong path
    XCTAssertNil(mytrie.delete(valueA, at:pathB),nok)
    XCTAssertNil(mytrie.delete(valueB, at:pathA),nok)

    // delete value a from path a
    XCTAssertEqual(valueA, mytrie.delete(valueA, at:pathA),nok)
    XCTAssertFalse(mytrie.isEmpty,nok)
    //

    // delete value b from path b
    XCTAssertEqual(valueB, mytrie.delete(valueB,at:pathB),nok)
    XCTAssertTrue(mytrie.isEmpty,nok)
  }
}
