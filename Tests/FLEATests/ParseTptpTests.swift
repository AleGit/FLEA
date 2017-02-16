import XCTest

@testable import FLEA

public class ParseTptpTests
: FleaTestCase // deactivated
{
  static var allTests: [(String, (ParseTptpTests) -> () throws -> Void)] {
    return [
      ("testParseHWV001", testParseHWV001),
      // ("testParseHWV106toSimpleNodes", testParseHWV106toSimpleNodes),
      // ("testParseHWV106toSharingNodes", testParseHWV106toSharingNodes),
      // ("testParseHWV106toSmartNodes", testParseHWV106toSmartNodes),
      // ("testParseHWV106toKinNodes", testParseHWV106toKinNodes)
    ]
  }

  /// [HWV001-1](http://www.cs.miami.edu/~tptp/cgi-bin/SeeTPTP?Category=Problems&Domain=HWV&File=HWV001-1.p)
  /// [Axioms/HWC002-0.ax]http://www.cs.miami.edu/~tptp/cgi-bin/SeeTPTP?Category=Axioms&File=HWC002-0.ax
  func testParseHWV001() {
    typealias NodeType = Q.SimpleNode
    // include('Axioms/HWC002-0.ax').
    let inputs: [NodeType] = Q.parse(problem:"HWV001-1")
    XCTAssertEqual(47, inputs.count, nok)
  }

  func _testParseHWV106toSimpleNodes() {
    typealias NodeType = Q.SimpleNode
    let inputs: [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949, inputs.count, nok)
  }

  func _testParseHWV106toSharingNodes() {
    typealias NodeType = Q.SharingNode
    let inputs: [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949, inputs.count, nok)
    XCTAssertEqual(807725, NodeType.pool.count)
  }

  func _testParseHWV106toSmartNodes() {
    typealias NodeType = Q.SmartNode
    let inputs: [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949, inputs.count, nok)
    XCTAssertEqual(807725, NodeType.pool.count, nok)
    XCTAssertEqual(0, NodeType.pool.collisionCount, nok)
  }

  func _testParseHWV106toKinNodes() {
    typealias NodeType = Q.KinNode
    let inputs: [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949, inputs.count, nok)
    XCTAssertEqual(807725, NodeType.pool.count, nok)
    XCTAssertEqual(0, NodeType.pool.collisionCount, nok)
  }
}
