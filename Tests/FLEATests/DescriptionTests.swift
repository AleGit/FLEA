import XCTest

@testable import FLEA

public class DescriptionTests: FleaTestCase {

    static var allTests: [(String, (DescriptionTests) -> () throws -> Void)] {
        return [
            ("testDescription", testDescription),
            ("testDebugDescription", testDebugDescription),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalKinIntNode: SymbolNameTyped, SymbolTabulating, Sharing, Kin, Node {
        typealias S = Int

        static var symbols = StringIntegerTable<S>()
        static var pool = WeakSet<LocalKinIntNode>()
        var folks = WeakSet<LocalKinIntNode>()

        var symbol: S = LocalKinIntNode.symbolize(string: "*", type: .variable)
        var nodes: [LocalKinIntNode]?

        lazy var description: String = self.defaultDescription
    }

    func testDescription() {
        let a = LocalKinIntNode(c: "a")
        let X = LocalKinIntNode(v: "X")
        let fXa = LocalKinIntNode(f: "f", [X, a])

        XCTAssertEqual("a", a.description, nok)
        XCTAssertEqual("X", X.description, nok)

        XCTAssertEqual("f(X,a)", fXa.description, nok)
    }

    func testDebugDescription() {
        let a = LocalKinIntNode(c: "a")
        let X = LocalKinIntNode(v: "X")
        let fXa = LocalKinIntNode(f: "f", [X, a])

        let equals = LocalKinIntNode.symbolize(string: "=", type: .equation)
        let a_X = LocalKinIntNode(symbol: equals, nodes: [a, X])

        XCTAssertEqual("1-a-function(0)", a.debugDescription, nok)
        XCTAssertEqual("2-X-variable", X.debugDescription, nok)

        XCTAssertEqual("3-f-function(2)(2-X-variable,1-a-function(0))", fXa.debugDescription, nok)

        XCTAssertEqual("4-=-equation(1-a-function(0),2-X-variable)", a_X.debugDescription, nok)

        XCTAssertEqual("a", a.description, nok)
        XCTAssertEqual("X", X.description, nok)
        XCTAssertEqual("f(X,a)", fXa.description, nok)
        XCTAssertEqual("a=X", a_X.description, nok)
    }
}
