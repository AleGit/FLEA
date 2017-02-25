import XCTest

@testable import FLEA

public class TrieTests: FleaTestCase {
    static var allTests: [(String, (TrieTests) -> () throws -> Void)] {
        return [
            ("testTrieStruct", testTrieStruct),
            ("testTrieClass", testTrieClass),
            ("testUnifiables", testUnifiables),
            ("testPrefixes", testPrefixes),
        ]
    }

    lazy var pathA = [1, 4, 5, 6, 7, 8]
    lazy var valueA = "A"
    lazy var pathB = [1, 4, 5, 6, 1]
    lazy var valueB = "B"

    func testTrieStruct() {
        typealias T = FLEA.TrieStruct

        var mytrie = T<Int, String>()
        var mytrie2 = T(with: valueA, at: pathA)

        XCTAssertTrue(mytrie.isEmpty, nok)
        mytrie.insert(valueA, at: pathA)
        XCTAssertEqual(mytrie, mytrie2, nok)

        mytrie.insert(valueB, at: pathB)
        mytrie2.insert(valueB, at: pathB)
        XCTAssertEqual(mytrie, mytrie2, nok)

        // let values : Set = [valueA, valueB]
        // XCTAssertEqual(values, mytrie.values)

        // remove values from wrong path
        XCTAssertNil(mytrie.remove(valueA, at: pathB), nok)
        XCTAssertNil(mytrie.remove(valueB, at: pathA), nok)

        // remove value a from path a
        XCTAssertEqual(valueA, mytrie.remove(valueA, at: pathA), nok)
        XCTAssertFalse(mytrie.isEmpty, nok)

        // remove value b from path b
        XCTAssertEqual(valueB, mytrie.remove(valueB, at: pathB), nok)
        XCTAssertTrue(mytrie.isEmpty, nok)

        XCTAssertEqual(mytrie2.retrieve(from: pathA)!, Set([valueA]))
        XCTAssertEqual(mytrie2.retrieve(from: pathB)!, Set([valueB]))
        XCTAssertEqual(mytrie2.retrieve(from: [Int]())!, Set<String>())

        XCTAssertEqual(mytrie2.retrieve(from: [1])!, Set<String>())
        XCTAssertNil(mytrie2.retrieve(from: [2]))
    }

    func testTrieClass() {
        typealias T = FLEA.TrieClass

        var mytrie = T<Int, String>()
        var mytrie2 = T(with: valueA, at: pathA)

        XCTAssertTrue(mytrie.isEmpty, nok)
        mytrie.insert(valueA, at: pathA)
        XCTAssertEqual(mytrie, mytrie2, nok)

        mytrie.insert(valueB, at: pathB)
        mytrie2.insert(valueB, at: pathB)
        XCTAssertEqual(mytrie, mytrie2, nok)

        // remove values from wrong path
        XCTAssertNil(mytrie.remove(valueA, at: pathB), nok)
        XCTAssertNil(mytrie.remove(valueB, at: pathA), nok)

        // remove value a from path a
        XCTAssertEqual(valueA, mytrie.remove(valueA, at: pathA), nok)
        XCTAssertFalse(mytrie.isEmpty, nok)
        //

        // remove value b from path b
        XCTAssertEqual(valueB, mytrie.remove(valueB, at: pathB), nok)
        XCTAssertTrue(mytrie.isEmpty, nok)
    }

    // swiftlint:disable function_body_length
    func testUnifiables() {
        typealias N = FLEA.Tptp.KinIntNode
        typealias T = FLEA.TrieClass

        let wildcard = N.symbolize(string:Tptp.wildcard, type:.variable)
        XCTAssertEqual(wildcard, -1, "Integer symbol wildcard MUST be -1 \(nok)")

        let X = "X" as N
        let fX = "f(X)" as N // 1
        let fc = "f(c)" as N // 2
        let fd = "f(d)" as N // 3
        let fgXY = "f(g(X,Y))" as N // 4
        let fgXfY = "f(g(X,f(Y)))" as N // 5
        let gXY = "g(X,Y)" as N
        let gcY = "g(c,Y)" as N
        let gXd = "g(X,d)" as N
        let gcd = "g(c,d)" as N
        let gfXY = "g(f(X),Y)" as N
        let gXfY = "g(X,f(Y))" as N

        let terms = [
            X, // 0
            fX, fc, fd, // 1,2,3
            fgXY, fgXfY, // 4,5
            gXY, gXd, gcY, gcd, // 6,7,8,9
            gfXY, gXfY, // 10,11
        ]

        var trie = T<Int, Int>()

        for (idx, term) in terms.enumerated() {
            for path in term.leafPaths {
                trie.insert(idx, at: path)
            }
        }

        var unifiables = trie.unifiables(paths: X.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set(0 ..< terms.count), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: fX.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 1, 2, 3, 4, 5]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: fc.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 1, 2]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: fd.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 1, 3]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: fgXY.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 1, 4, 5]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: fgXfY.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 1, 4, 5]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: gXY.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 6, 7, 8, 9, 10, 11]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: gXd.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 6, 7, 8, 9, 10]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: gcY.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 6, 7, 8, 9, 11]), unifiables, "\(nok) \(unifiables)")

        unifiables = trie.unifiables(paths: gcd.leafPaths, wildcard: wildcard)
        XCTAssertEqual(Set([0, 6, 7, 8, 9]), unifiables, "\(nok) \(unifiables)")
    }

    func testPrefixes() {
        typealias T = FLEA.TrieClass
        var trie = T<Character, String>()

        let all = Set([
            "a", "b", "aa", "ab", "ba", "ba", "*",
        ])

        for s in all {
            trie.insert(s, at: s.characters)
        }

        var matches = trie.unifiables(paths: [["a"]], wildcard: "*")
        XCTAssertEqual(Set(["a", "aa", "ab", "*"]), matches, "\(nok) \(matches)")

        matches = trie.unifiables(paths: [["*"]], wildcard: "*")
        XCTAssertEqual(all, matches, "\(nok) \(matches)")

        matches = trie.unifiables(paths: [["a", "*"]], wildcard: "*")
        XCTAssertEqual(Set(["a", "aa", "ab", "*"]), matches, "\(nok) \(matches)")
    }
}
