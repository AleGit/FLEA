import XCTest

@testable import FLEA

public class NodePropertiesTests: FleaTestCase {
    typealias T = NodePropertiesTests

    static var allTests: [(String, (NodePropertiesTests) -> () throws -> Void)] {
        return [
            ("testInit", testHeight),
            ("testWidth", testWidth),
            ("testSize", testSize),
            ("testSharing", testSharing),
            ("testKin", testKin),
            ("testHashValue", testHashValue),
            ("testDescription", testDescription),
        ]
    }

    public override class func setUp() {
        super.setUp() // carping is off
        Syslog.carping = true // carping is on
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalKinIntNode: SymbolNameTyped, SymbolTabulating, Sharing, Kin, Node,
        ExpressibleByStringLiteral {
        static var symbols = StringIntegerTable<Int>() // : SymbolTabulating
        static var pool = WeakSet<LocalKinIntNode>() // : Sharing
        var folks = WeakSet<LocalKinIntNode>() // : Kin

        var symbol: Int = LocalKinIntNode.symbolize(string: "*", type: .variable) // : Node
        var nodes: [LocalKinIntNode]? // : Node

        // lazy evaluation and memorizing of node dimensions

        lazy var hashValue: Int = self.defaultHashValue
        lazy var description: String = self.defaultDescription

        lazy var dimensions: (
            // subnodes: Set<LocalKinIntNode>,
            // variables: Set<LocalKinIntNode>,
            height: Int,
            width: Int,
            size: Int
        ) = self.defaultDimensions

        static let a = "a" as LocalKinIntNode
        static let X = "X" as LocalKinIntNode
        static let faX = "f(a,X)" as LocalKinIntNode
        static let f2 = "f(g(X),f(a,g(b)))" as LocalKinIntNode
        static let clause = "p(X)|q(a)" as LocalKinIntNode

        static let _a = "a" as LocalKinIntNode
        static let _X = "X" as LocalKinIntNode
        static let _faX = "f(a,X)" as LocalKinIntNode
        static let _f2 = "f(g(X),f(a,g(b)))" as LocalKinIntNode
    }

    func testHeight() {
        XCTAssertEqual(0, LocalKinIntNode.a.height, nok)
        XCTAssertEqual(0, LocalKinIntNode.X.height, nok)
        XCTAssertEqual(1, LocalKinIntNode.faX.height, nok)
    }

    func testWidth() {
        XCTAssertEqual(1, LocalKinIntNode.a.width, nok)
        XCTAssertEqual(1, LocalKinIntNode.X.width, nok)
        XCTAssertEqual(2, LocalKinIntNode.faX.width, nok)
    }

    func testSize() {
        XCTAssertEqual(1, LocalKinIntNode.a.size, nok)
        XCTAssertEqual(1, LocalKinIntNode.X.size, nok)
        XCTAssertEqual(3, LocalKinIntNode.faX.size, nok)
    }

    func testSharing() {
        XCTAssertTrue(LocalKinIntNode.a === LocalKinIntNode._a, nok)
        XCTAssertTrue(LocalKinIntNode.X === LocalKinIntNode._X, nok)
        XCTAssertTrue(LocalKinIntNode.faX === LocalKinIntNode._faX, nok)

        XCTAssertTrue(LocalKinIntNode.a === LocalKinIntNode.faX.nodes!.first!, nok)
        XCTAssertTrue(LocalKinIntNode.X === LocalKinIntNode.faX.nodes!.last!, nok)

        XCTAssertTrue(LocalKinIntNode.a === LocalKinIntNode.f2.nodes!.last!.nodes!.first!, nok)
        XCTAssertTrue(LocalKinIntNode.X === LocalKinIntNode.f2.nodes!.first!.nodes!.first!, nok)

        XCTAssertTrue(LocalKinIntNode.f2 === LocalKinIntNode._f2, nok)
    }

    func testKin() {
        typealias N = LocalKinIntNode
        _ = [N.a, N.X, N.faX, N.f2, N.clause]

        var expected: [N] = [N.faX, "f(a,g(b))", N.clause.nodes!.last!]
        XCTAssertEqual(Set(expected), Set(LocalKinIntNode.a.folks), nok)

        expected = [LocalKinIntNode.faX, "g(X)", LocalKinIntNode.clause.nodes!.first!]
        XCTAssertEqual(Set(expected), Set(LocalKinIntNode.X.folks), nok)

        expected = [LocalKinIntNode]()
        XCTAssertEqual(Set(expected), Set(LocalKinIntNode.faX.folks), nok)

        expected = [LocalKinIntNode]()
        XCTAssertEqual(Set(expected), Set(LocalKinIntNode.f2.folks), nok)

        expected = [LocalKinIntNode.f2]
        XCTAssertEqual(Set(expected), Set(("g(X)" as LocalKinIntNode).folks), nok)
        XCTAssertEqual(Set(expected), Set(("f(a,g(b))" as LocalKinIntNode).folks), nok)

        expected = [LocalKinIntNode.faX, "f(a,g(b))", "g(a)", LocalKinIntNode.clause.nodes!.last!]
        XCTAssertEqual(Set(expected), Set(LocalKinIntNode.a.folks), nok)

        expected = ["g(f(a,X))"]
        XCTAssertEqual(Set(expected), Set(LocalKinIntNode.faX.folks), nok)
    }

    func testHashValue() {

        XCTAssertEqual(LocalKinIntNode.faX.hashValue, LocalKinIntNode.faX.defaultHashValue, nok)

        XCTAssertNotEqual(LocalKinIntNode.a.hashValue, LocalKinIntNode.X.hashValue, nok)
        XCTAssertNotEqual(LocalKinIntNode.a.hashValue, LocalKinIntNode.faX.hashValue, nok)
        XCTAssertNotEqual(LocalKinIntNode.a.hashValue, LocalKinIntNode.f2.hashValue, nok)

        XCTAssertNotEqual(LocalKinIntNode.X.hashValue, LocalKinIntNode.faX.hashValue, nok)
        XCTAssertNotEqual(LocalKinIntNode.X.hashValue, LocalKinIntNode.f2.hashValue, nok)

        XCTAssertNotEqual(LocalKinIntNode.faX.hashValue, LocalKinIntNode.f2.hashValue, nok)
    }

    func testDescription() {
        XCTAssertEqual("f(a,X)", LocalKinIntNode.faX.defaultDescription, nok)
        XCTAssertEqual("f(g(X),f(a,g(b)))", LocalKinIntNode.f2.defaultDescription, nok)
        XCTAssertEqual(LocalKinIntNode.faX.description, LocalKinIntNode.faX.defaultDescription, nok)
    }
}
