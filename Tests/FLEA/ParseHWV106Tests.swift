import XCTest

@testable import FLEA

public class ParseHWV106Tests
// : XCTestCase // deactivated
{
  static var allTests : [(String, (ParseHWV106Tests) -> () throws -> Void)] {
    return [
      ("testSimpleNode", testSimpleNode)
    ]
  }

  func testSimpleNode() {
    typealias NodeType = Tptp.SimpleNode
    let inputs : [NodeType] = Misc.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
  }

  func testSharingNode() {
    typealias NodeType = Tptp.SharingNode
    let inputs : [NodeType] = Misc.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.pool.count)
  }

  func testSmartNode() {
    typealias NodeType = Tptp.SmartNode
    let inputs : [NodeType] = Misc.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.pool.count,nok)
    XCTAssertEqual(0, NodeType.pool.collisionCount,nok)
  }

  func testKinNode() {
    typealias NodeType = Tptp.KinNode
    let inputs : [NodeType] = Misc.parse(problem:"HWV106-1")
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.pool.count,nok)
    XCTAssertEqual(0, NodeType.pool.collisionCount,nok)
  }
}
