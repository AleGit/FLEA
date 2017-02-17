import XCTest

@testable import FLEA

/// Test the accumulation of nodes in Q.LocalSharingNode.pool.
/// Nodes MAY accumulate between tests.
public class SharingNodeTests: FleaTestCase {
    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (SharingNodeTests) -> () throws -> Void)] {
        return [
            ("testEqualityX", testEqualityX),
            ("testEqualityY", testEqualityY),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalSharingNode: SymbolStringTyped, Sharing, Node {
        typealias S = Tptp.Symbol
        static var pool = Set<LocalSharingNode>()

        var symbol: S = LocalSharingNode.symbolize(string: "*", type: .variable)
        var nodes: [LocalSharingNode]?

        deinit {
            print("\(#function) \(self)")
        }
    }

    /// accumulate additional four distict nodes
    func testEqualityX() {

        let X = LocalSharingNode(v: "X")
        let a = LocalSharingNode(c: "a")
        let fX = LocalSharingNode(f: "f", [X])
        let fa = LocalSharingNode(f: "f", [a])

        let fX_a = fX * [LocalSharingNode(v: "X"): LocalSharingNode(c: "a")]

        XCTAssertEqual(fX_a, fa)
        XCTAssertTrue(fX_a == fa)
        XCTAssertTrue(fX_a === fa)

        let count = LocalSharingNode.pool.count
        XCTAssertTrue(count >= 4, "\(nok)  \(#function) Just \(count) < 4 sharing nodes accumulated.")

        if count > 4 {
            print("\(ok)  \(#function) \(count) sharing nodes accumulated between tests.")
        }
    }

    /// accumulate additional four distict nodes
    func testEqualityY() {

        let X = LocalSharingNode(v: "Y")
        let a = LocalSharingNode(c: "a")
        let fX = LocalSharingNode(f: "f", [X])
        let fa = LocalSharingNode(f: "f", [a])

        let fX_a = fX * [LocalSharingNode(v: "Y"): LocalSharingNode(c: "a")]

        XCTAssertEqual(fX_a, fa)
        XCTAssertTrue(fX_a == fa)
        XCTAssertTrue(fX_a === fa)

        let count = LocalSharingNode.pool.count
        XCTAssertTrue(count >= 4, "\(nok)  \(#function) Just \(count) < 4 sharing nodes accumulated.")

        if count > 4 {
            print("\(ok)  \(#function) \(count) sharing nodes accumulated between tests.")
        }
    }
}
