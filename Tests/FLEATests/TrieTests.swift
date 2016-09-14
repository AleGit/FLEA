import XCTest

@testable import FLEA

public class TrieTests: FleaTestCase {
  static var allTests: [(String, (TrieTests) -> () throws -> Void)] {
    return [
    ("testTrieStruct", testTrieStruct),
    ("testTrieClass", testTrieClass),
    ("testCandidates", testCandidates)
    ]
  }

  lazy var pathA = [1, 4, 5, 6, 7, 8]
  lazy var valueA = "A"
  lazy var pathB = [1, 4, 5, 6, 1]
  lazy var valueB = "B"

  func testTrieStruct() {
    typealias T = FLEA.TrieStruct

    var mytrie = T<Int, String>()
    var mytrie2 = T(with:valueA, at:pathA)

    XCTAssertTrue(mytrie.isEmpty, nok)
    mytrie.insert(valueA, at:pathA)
    XCTAssertEqual(mytrie, mytrie2, nok)

    mytrie.insert(valueB, at:pathB)
    mytrie2.insert(valueB, at:pathB)
    XCTAssertEqual(mytrie, mytrie2, nok)

    // let values : Set = [valueA, valueB]
    // XCTAssertEqual(values, mytrie.values)

    // remove values from wrong path
    XCTAssertNil(mytrie.remove(valueA, at:pathB), nok)
    XCTAssertNil(mytrie.remove(valueB, at:pathA), nok)

    // remove value a from path a
    XCTAssertEqual(valueA, mytrie.remove(valueA, at:pathA), nok)
    XCTAssertFalse(mytrie.isEmpty, nok)

    // remove value b from path b
    XCTAssertEqual(valueB, mytrie.remove(valueB, at:pathB), nok)
    XCTAssertTrue(mytrie.isEmpty, nok)

    XCTAssertEqual(mytrie2.retrieve(from:pathA)!, Set([valueA]))
    XCTAssertEqual(mytrie2.retrieve(from:pathB)!, Set([valueB]))
    XCTAssertEqual(mytrie2.retrieve(from:[Int]())!, Set<String>())

    XCTAssertEqual(mytrie2.retrieve(from:[1])!, Set<String>())
    XCTAssertNil(mytrie2.retrieve(from:[2]))
  }

  func testTrieClass() {
    typealias T = FLEA.TrieClass

    var mytrie = T<Int, String>()
    var mytrie2 = T(with:valueA,at:pathA)

    XCTAssertTrue(mytrie.isEmpty, nok)
    mytrie.insert(valueA, at:pathA)
    XCTAssertEqual(mytrie, mytrie2, nok)

    mytrie.insert(valueB, at:pathB)
    mytrie2.insert(valueB, at:pathB)
    XCTAssertEqual(mytrie, mytrie2, nok)

    // remove values from wrong path
    XCTAssertNil(mytrie.remove(valueA, at:pathB), nok)
    XCTAssertNil(mytrie.remove(valueB, at:pathA), nok)

    // remove value a from path a
    XCTAssertEqual(valueA, mytrie.remove(valueA, at:pathA), nok)
    XCTAssertFalse(mytrie.isEmpty, nok)
    //

    // remove value b from path b
    XCTAssertEqual(valueB, mytrie.remove(valueB, at:pathB), nok)
    XCTAssertTrue(mytrie.isEmpty, nok)
  }

  func testCandidates() {
    typealias T = FLEA.TrieClass

    let v = -1 // variable *

    let c = 4 // constant
    let d = 5 // constant
    let f = 1 // unary
    let g = 2 // binary
    let h = 3 // tertiary

    let fxPaths = [ [f, 0, v] ]
    let fcPaths = [ [f, 0, c] ]
    let fdPaths = [ [f, 0, d] ]

    let gxyPaths = [[g, 0, v], [g, 1, v]]
    let gxcPaths = [[g, 0, v], [g, 1, c]]
    let gcyPaths = [[g, 0, c], [g, 1, v]]
    let gcdPaths = [[g, 0, c], [g, 1, d]]

    let ppp = [
      fxPaths, fcPaths, fdPaths,
      gxyPaths, gxcPaths, gcyPaths, gcdPaths
    ]

    var trie = T<Int, Int>()

    for (idx, paths) in ppp.enumerated() {
      for path in paths {
        trie.insert(idx, at:path)
      }
    }

    var unifiables = trie.unifiables(path: [v], asterisk: v)
    var candidates = trie.candidates(from: [v])
    XCTAssertEqual(Set(0..<ppp.count), unifiables, "\(nok) \(unifiables)")
    XCTAssertEqual(Set(0..<ppp.count), candidates, "\(nok) \(candidates)")

    unifiables = trie.unifiables(path: fxPaths.first!, asterisk: v)
    candidates = trie.candidates(from: fxPaths.first!)
    XCTAssertEqual(Set([0, 1, 2]), unifiables, "\(nok) \(unifiables)")
    XCTAssertEqual(Set([0, 1, 2]), candidates, "\(nok) \(candidates)")


  }
}
