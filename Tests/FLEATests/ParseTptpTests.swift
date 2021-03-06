import XCTest

@testable import FLEA

public class ParseTptpTests {
    static var allTests: [(String, (ParseTptpTests) -> () throws -> Void)] {
        return [
            // ("testParseHWV106toSimpleNodes", testParseHWV106toSimpleNodes),
            // ("testParseHWV106toSharingNodes", testParseHWV106toSharingNodes),
            // ("testParseHWV106toSmartNodes", testParseHWV106toSmartNodes),
            // ("testParseHWV106toKinNodes", testParseHWV106toKinNodes)
        ]
    }

    func _testParseHWV106toSimpleNodes() {
        typealias NodeType = Q.SimpleNode
        let inputs: [NodeType] = Q.parse(problem: "HWV106-1")
        XCTAssertEqual(287_949, inputs.count, nok)
    }

    func _testParseHWV106toSharingNodes() {
        typealias NodeType = Q.SharingNode
        let inputs: [NodeType] = Q.parse(problem: "HWV106-1")
        XCTAssertEqual(287_949, inputs.count, nok)
        XCTAssertEqual(807_725, NodeType.pool.count)
    }

    func _testParseHWV106toSmartNodes() {
        typealias NodeType = Q.SmartNode
        let inputs: [NodeType] = Q.parse(problem: "HWV106-1")
        XCTAssertEqual(287_949, inputs.count, nok)
        XCTAssertEqual(807_725, NodeType.pool.count, nok)
        XCTAssertEqual(0, NodeType.pool.collisionCount, nok)
    }

    func _testParseHWV106toKinNodes() {
        typealias NodeType = Q.KinNode
        let inputs: [NodeType] = Q.parse(problem: "HWV106-1")
        XCTAssertEqual(287_949, inputs.count, nok)
        XCTAssertEqual(807_725, NodeType.pool.count, nok)
        XCTAssertEqual(0, NodeType.pool.collisionCount, nok)
    }
}
