import XCTest
@testable import FLEA

public class AuxiliaryTests: FleaTestCase {
    static var allTests: [(String, (AuxiliaryTests) -> () throws -> Void)] {
        return [
            ("testCollectionDecomposing", testCollectionDecomposing),
            ("testSequence", testSequence),
            ("testAllOneCount", testAllOneCount), // Sequence
            ("testStringIsUppercased", testStringIsUppercased),
            ("testStringContainsAllOne", testStringContainsAllOne),
            ("testIds", testIds),
        ]
    }

    /// test auxiliary extensions of collections
    func testCollectionDecomposing() {
        let array = [11, 12, 13]
        guard let (h1, t1) = array.decomposing else {
            XCTFail(nok)
            return
        }
        XCTAssertEqual(11, h1, nok)
        guard let (h2, t2) = t1.decomposing else {
            XCTFail(nok)
            return
        }
        XCTAssertEqual(12, h2, nok)

        guard let (h3, t3) = t2.decomposing else {
            XCTFail(nok)
            return
        }
        XCTAssertEqual(13, h3, nok)

        XCTAssertNil(t3.decomposing, nok)
    }

    /// test auxiliary extensions of sequences
    func testSequence() {
        let names = ["Äbel", "Bärta", "Cornelium", "Doris", "Earnest"]

        XCTAssertTrue(names.all { $0.count > 3 }, "Not all names has more than three characters. \(nok)")
        XCTAssertFalse(names.all { $0.count > 4 }, "All numbers has more than four characters. \(nok)")

        XCTAssertTrue(names.one { $0.count > 8 }, "No name has more than eight characters. \(nok)")
        XCTAssertFalse(names.one { $0.count > 9 }, "A name has more than nine characters. \(nok)")

        XCTAssertEqual(names.count, names.count { $0.count > 3 }, nok)
        XCTAssertEqual(2, names.count { $0.count > 5 }, nok)
        XCTAssertEqual(0, names.count { $0.count > 9 }, nok)
    }

    func testAllOneCount() {
        let array = [2, 3, 5, 7, 11, 13]

        var checks = 0
        XCTAssertFalse(array.all {
            checks += 1
            return $0 % 2 == 0
        }, nok)
        XCTAssertEqual(2, checks, nok)

        checks = 0
        XCTAssertTrue(array.one {
            checks += 1
            return $0 % 2 == 0
        }, nok)
        XCTAssertEqual(1, checks)

        checks = 0
        XCTAssertTrue(array.all {
            checks += 1
            return $0 > 1
        }, nok)
        XCTAssertEqual(array.count, checks)

        checks = 0
        XCTAssertFalse(array.one {
            checks += 1
            return $0 < 1
        }, nok)
        XCTAssertEqual(array.count, checks)

        // count even elements
        XCTAssertEqual(1, array.count { $0 % 2 == 0 }, nok)

        // count all elements
        XCTAssertEqual(array.count, array.count(), nok)

        // count elements > 4
        XCTAssertEqual(4, array.count { $0 > 4 }, nok)

        // count elements > 1
        XCTAssertEqual(array.count, array.count { $0 > 1 }, nok)

        // count elements < 1
        XCTAssertEqual(0, array.count { $0 < 1 }, nok)
    }

    func testStringIsUppercased() {
        let u = "Flea"
        let l = "flea"

        XCTAssertTrue(u.isUppercased(at: u.startIndex), nok)
        XCTAssertFalse(l.isUppercased(at: l.startIndex), nok)

        let ü = "ÜbÉr"
        let ä = "älter"

        print(ü, ü.map { $0 })

        XCTAssertTrue(ü.isUppercased(at: ü.startIndex), nok)
        XCTAssertFalse(ü.isUppercased(at: ü.index(after: ü.startIndex)))
        XCTAssertTrue(ü.isUppercased(at: ü.index(ü.startIndex, offsetBy: 2)))
        XCTAssertFalse(ü.isUppercased(at: ü.index(before: ü.endIndex)))

        XCTAssertFalse(ä.isUppercased(at: ä.startIndex), nok)
    }

    func testStringContainsAllOne() {
        let string = "Héllo, Wörld!" // a non-empty string
        let ε = "" // the empty string

        // a string contains ALL characters of an empty collection
        XCTAssertTrue(string.containsAll([String]()), nok)
        XCTAssertTrue(ε.containsAll([String]()), nok)

        // An arbitrary string does NOT contain ONE character of an empty collection.
        XCTAssertFalse(string.containsOne([String]()), nok)
        XCTAssertFalse(ε.containsOne([String]()), nok)

        // An arbitrary string contains ALL of its characters.
        XCTAssertTrue(string.containsAll(string.map { String($0) }), nok)
        XCTAssertTrue(ε.containsAll(ε.map { String($0) }), nok)

        // A non-empty string contains ONE of its characters.
        XCTAssertTrue(string.containsOne(string.map { String($0) }), nok)
        // ⚠️  The empty string does NOT contain ONE of its characters.
        XCTAssertFalse(ε.containsOne(ε.map { String($0) }), nok)

        // A non-empty string MAY contain ONE or ALL characters of a non-empty collection.
        XCTAssertTrue(string.containsOne(["x", "ä", "é"]), nok)
        XCTAssertFalse(string.containsAll(["x", "ä", "é"]), nok)
        XCTAssertFalse(string.containsOne(["x", "ä", "?"]), nok)
        XCTAssertTrue(string.containsAll(["o", "ö", "!"]), nok)

        // The empty string does NOT contain ALL or ONE characters of a non-empty collection.
        XCTAssertFalse(ε.containsOne(["x", "ä", "é"]), nok)
        XCTAssertFalse(ε.containsAll(["x", "ä", "é"]), nok)
        XCTAssertFalse(ε.containsOne(["x", "ä", "?"]), nok)
        XCTAssertFalse(ε.containsAll(["o", "ö", "!"]), nok)
    }

    func testIds() {
        let `$` = "$"
        XCTAssertEqual(`$`, "$")
        let a$ = "a$"
        XCTAssertEqual(a$, "a$")
        // let $a = "$a" // error: expected numeric value following '$'
        // XCTAssertEqual($a,"$a")
        let a$a = "a$a"
        XCTAssertEqual(a$a, "a$a")

        let € = "?"
        XCTAssertEqual(€, "?")
        let a€ = "?"
        XCTAssertEqual(a€, "?")
        let €a = "?"
        XCTAssertEqual(€a, "?")
        let a€a = "?"
        XCTAssertEqual(a€a, "?")
    }
}
