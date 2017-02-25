import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class KinNodeTests: FleaTestCase {
    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (KinNodeTests) -> () throws -> Void)] {
        return [
            ("testEqualityX", testEqualityX),
            ("testEqualityY", testEqualityY),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalKinIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node,
        ExpressibleByStringLiteral {
        typealias S = Int
        static var symbols = StringIntegerTable<S>()
        static var pool = WeakSet<LocalKinIntNode>()
        var folks = WeakSet<LocalKinIntNode>()

        var symbol: S = LocalKinIntNode.symbolize(string: Tptp.wildcard, type: .variable)
        var nodes: [LocalKinIntNode]?
    }

    /// accumulate four distict nodes
    func testEqualityX() {
        let symbol = LocalKinIntNode.symbolize(string: "*", type: .variable)
        XCTAssertEqual(-1, symbol)

        let X: LocalKinIntNode = "X"
        let a: LocalKinIntNode = "a"
        let fX = "f(X)" as LocalKinIntNode
        let fa = "f(a)" as LocalKinIntNode

        XCTAssertEqual("5-X-variable", X.debugDescription, nok)
        XCTAssertEqual("6-a-function(0)", a.debugDescription, nok)
        XCTAssertEqual("7-f-function(1)(5-X-variable)", fX.debugDescription, nok)
        XCTAssertEqual("7-f-function(1)(6-a-function(0))", fa.debugDescription, nok)

        // check if folks are set correctly

        XCTAssertTrue(X.folks.contains(fX), "\(nok)\n \(X.folks)")
        XCTAssertFalse(X.folks.contains(fa), "\(nok)\n \(X.folks)")
        XCTAssertTrue(a.folks.contains(fa), "\(nok)\n \(a.folks)")
        XCTAssertFalse(a.folks.contains(fX), "\(nok)\n \(a.folks)")

        let fX_a = fX * [LocalKinIntNode(v: "X"): LocalKinIntNode(c: "a")]

        // check if subtistuion sets folks correctly

        XCTAssertTrue(a.folks.contains(fX_a), "\(nok)\n \(a.folks)")
        XCTAssertFalse(X.folks.contains(fX_a), "\(nok)\n \(a.folks)")

        XCTAssertEqual(fX_a, fa, nok)
        XCTAssertTrue(fX_a == fa, nok)
        XCTAssertTrue(fX_a === fa, nok)

        let count = LocalKinIntNode.pool.count
        XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")
    }

    /// accumulate four distict nodes
    func testEqualityY() {

        let X = LocalKinIntNode(v: "Y")
        let a = LocalKinIntNode(c: "a")
        let fX = LocalKinIntNode(f: "f", [X])
        let fa = LocalKinIntNode(f: "f", [a])

        let fX_a = fX * [LocalKinIntNode(v: "Y"): LocalKinIntNode(c: "a")]

        XCTAssertEqual(fX_a, fa, nok)
        XCTAssertTrue(fX_a == fa, nok)
        XCTAssertTrue(fX_a === fa, nok)

        let count = LocalKinIntNode.pool.count
        XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")
    }
}
