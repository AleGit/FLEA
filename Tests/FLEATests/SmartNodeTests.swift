import XCTest

@testable import FLEA

/// Test the accumulation of nodes in LocalSmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class SmartNodeTests: FleaTestCase {
    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (SmartNodeTests) -> () throws -> Void)] {
        return [
            ("testEqualityX", testEqualityX),
            ("testEqualityY", testEqualityY),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalSmartNode: SymbolStringTyped, Sharing, Node {
        typealias S = Tptp.Symbol // choose the symbol
        static var pool = WeakSet<LocalSmartNode>()

        var symbol: S = LocalSmartNode.symbolize(string: "*", type: .variable)
        var nodes: [LocalSmartNode]?

        lazy var hashValue: Int = self.defaultHashValue
        lazy var description: String = self.defaultDescription

        deinit {
            print("\(#function) \(self)")
        }
    }

    /// accumulate four distict nodes
    func testEqualityX() {
        typealias N = LocalSmartNode

        let X = LocalSmartNode(v: "X")
        let a = LocalSmartNode(c: "a")
        let fX = LocalSmartNode(f: "f", [X])
        let fa = LocalSmartNode(f: "f", [a])

        let fX_a = fX * [LocalSmartNode(v: "X"): LocalSmartNode(c: "a")]

        XCTAssertEqual(fX_a, fa)
        XCTAssertTrue(fX_a == fa)
        XCTAssertTrue(fX_a === fa)
        XCTAssertTrue(fX.nodes!.first! == X)
        XCTAssertTrue(fa.nodes!.first! == a)

        let count = LocalSmartNode.pool.count
        XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

        let ffa = N(f: "f", [N(f: "f", [N(v: "Y")])]) * [N(v: "Y"): N(c: "a")]
        XCTAssertEqual(5, N.pool.count, "\(nok)  \(#function) \(count) ≠ 5 smart nodes accumulated.")
        let g = fX * [X: fa]
        XCTAssertEqual(5, N.pool.count, "\(nok)  \(#function) \(count) ≠ 5 smart nodes accumulated.")
        XCTAssertTrue(ffa == g)

        XCTAssertFalse(N.pool.one { $0.symbolStringType.0 == "Y" }) /// Y must not be stored
    }

    /// accumulate four distict nodes
    func testEqualityY() {

        let X = LocalSmartNode(v: "Y")
        let a = LocalSmartNode(c: "a")
        let fX = LocalSmartNode(f: "f", [X])
        let fa = LocalSmartNode(f: "f", [a])

        let fX_a = fX * [LocalSmartNode(v: "Y"): LocalSmartNode(c: "a")]

        XCTAssertEqual(fX_a, fa)
        XCTAssertTrue(fX_a == fa)
        XCTAssertTrue(fX_a === fa)

        let count = LocalSmartNode.pool.count
        XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")
    }
}
