import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class NodePathsTests: FleaTestCase {
    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (NodePathsTests) -> () throws -> Void)] {
        return [
            ("testNodePaths", testNodePaths),
            ("testNegatedPaths", testNegatedPaths),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalKinIntNode: SymbolNameTyped, SymbolTabulating, Sharing, Kin, Node,
        ExpressibleByStringLiteral {
        typealias S = Int
        static var symbols = StringIntegerTable<Int>()
        static var pool = WeakSet<LocalKinIntNode>()
        var folks = WeakSet<LocalKinIntNode>()

        var symbol: S = LocalKinIntNode.symbolize(string: "*", type: .variable)
        var nodes: [LocalKinIntNode]?

        deinit {
            print("\(#function) \(self)")
        }

        var description: String {
            return defaultDescription
        }
    }

    /// accumulate four distinct nodes
    func testNodePaths() {

        let X = LocalKinIntNode(v: "X")
        let a = LocalKinIntNode(c: "a")
        let fX = LocalKinIntNode(f: "f", [X])
        let fa = LocalKinIntNode(f: "f", [a])
        let gfXfa = LocalKinIntNode(f: "g", [fX, fa])
        let ggfXfaX = LocalKinIntNode(f: "g", [gfXfa, X])

        let f$ = fX.symbol
        let g$ = gfXfa.symbol
        let _$ = LocalKinIntNode.symbols.insert("*", .variable)
        let a$ = a.symbol

        let count = LocalKinIntNode.pool.count
        XCTAssertEqual(count, 6, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

        let expected = [
            [g$, 0, g$, 0, f$, 0, -1],
            [g$, 0, g$, 1, f$, 0, a$],
            [g$, 1, -1],
        ]
        let actual = ggfXfaX.leafPaths
        XCTAssertEqual(
            expected.count,
            actual.count,
            nok
        )
        XCTAssertEqual(
            Array(expected.joined()),
            Array(actual.joined()),
            nok
        )

        // #endif
        XCTAssertEqual(
            [g$, g$, f$, _$, f$, a$, _$],
            ggfXfaX.preorderTraversalSymbols, nok
        )
    }

    func testNegatedPaths() {
        let pfx: LocalKinIntNode = "@fof p(f(X))" // p is predicate
        let npfx: LocalKinIntNode = "~p(f(X))"
        let a_X: LocalKinIntNode = "a = X"
        let a_n_X: LocalKinIntNode = "a != X"

        var expected = pfx.leafPathsPair.0
        var actual = npfx.leafPathsPair.1

        XCTAssertEqual(
            Array(expected.joined()),
            Array(actual.joined())
        )

        expected = npfx.leafPathsPair.0
        actual = pfx.leafPathsPair.1

        XCTAssertEqual(
            Array(expected.joined()),
            Array(actual.joined())
        )

        expected = a_X.leafPathsPair.0
        actual = a_n_X.leafPathsPair.1

        XCTAssertEqual(
            Array(expected.joined()),
            Array(actual.joined()),
            "\(a_X) \(a_n_X)"
        )

        expected = a_n_X.leafPathsPair.0
        actual = a_X.leafPathsPair.1

        XCTAssertEqual(
            Array(expected.joined()),
            Array(actual.joined()),
            "\(a_n_X) \(a_X)"
        )
    }
}
