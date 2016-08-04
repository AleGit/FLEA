import XCTest

@testable import FLEA

public class ParseTptpTests
// : XCTestCase // deactivated
{
  static var allTests : [(String, (ParseTptpTests) -> () throws -> Void)] {
    return [
      ("testParseHWV106toSimpleNodes", testParseHWV106toSimpleNodes),
      ("testParseHWV106toSharingNodes", testParseHWV106toSharingNodes),
      ("testParseHWV106toSmartNodes", testParseHWV106toSmartNodes),
      ("testParseHWV106toKinNodes", testParseHWV106toKinNodes)
    ]
  }

  func testParseHWV106toSimpleNodes() {
    typealias NodeType = Tptp.SimpleNode
    let inputs : [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
  }

  func testParseHWV106toSharingNodes() {
    typealias NodeType = Tptp.SharingNode
    let inputs : [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.pool.count)
  }

  func testParseHWV106toSmartNodes() {
    typealias NodeType = Tptp.SmartNode
    let inputs : [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.pool.count,nok)
    XCTAssertEqual(0, NodeType.pool.collisionCount,nok)
  }

  func testParseHWV106toKinNodes() {
    typealias NodeType = Tptp.KinNode
    let inputs : [NodeType] = Q.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.pool.count,nok)
    XCTAssertEqual(0, NodeType.pool.collisionCount,nok)
  }
}
