import XCTest

@testable import FLEA

public class TrieTests : XCTestCase {
  static var allTests : [(String, (TrieTests) -> () throws -> Void)] {
    return [
    ("testTrieStruct", testTrieStruct),
//    ("testTrieClass", testTrieClass)
    ]
  }

  lazy var pathA = [1,4,5,6,7,8]
  lazy var valueA = "A"
  lazy var pathB = [1,4,5,6,1]
  lazy var valueB = "B"

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

    // let values : Set = [valueA, valueB]
    // XCTAssertEqual(values,mytrie.values)

    // remove values from wrong path
    XCTAssertNil(mytrie.remove(valueA, at:pathB),nok)
    XCTAssertNil(mytrie.remove(valueB, at:pathA),nok)

    // remove value a from path a
    XCTAssertEqual(valueA, mytrie.remove(valueA, at:pathA),nok)
    XCTAssertFalse(mytrie.isEmpty,nok)

    // remove value b from path b
    XCTAssertEqual(valueB, mytrie.remove(valueB,at:pathB),nok)
    XCTAssertTrue(mytrie.isEmpty,nok)

    XCTAssertEqual(mytrie2.retrieve(from:pathA)!, Set([valueA]))
    XCTAssertEqual(mytrie2.retrieve(from:pathB)!, Set([valueB]))
    XCTAssertEqual(mytrie2.retrieve(from:[Int]())!, Set<String>())

    XCTAssertEqual(mytrie2.retrieve(from:[1])!, Set<String>())
    XCTAssertNil(mytrie2.retrieve(from:[2]))
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

    // remove values from wrong path
    XCTAssertNil(mytrie.remove(valueA, at:pathB),nok)
    XCTAssertNil(mytrie.remove(valueB, at:pathA),nok)

    // remove value a from path a
    XCTAssertEqual(valueA, mytrie.remove(valueA, at:pathA),nok)
    XCTAssertFalse(mytrie.isEmpty,nok)
    //

    // remove value b from path b
    XCTAssertEqual(valueB, mytrie.remove(valueB,at:pathB),nok)
    XCTAssertTrue(mytrie.isEmpty,nok)
  }
}
