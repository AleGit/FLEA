import XCTest

@testable import FLEA

public class NodeTests: FleaTestCase {
    static var allTests: [(String, (NodeTests) -> () throws -> Void)] {
        return [
            ("testInit", testInit),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private struct LocalNode: Node {
        var symbol: String = ""
        var nodes: [LocalNode]?
    }

    func testInit() {
        let a = LocalNode(constant: "a")
        let X = LocalNode(variable: "X")
        let faX = LocalNode(symbol: "f", nodes: [a, X])
        XCTAssertEqual("f(a,X)", faX.description)
    }
}
