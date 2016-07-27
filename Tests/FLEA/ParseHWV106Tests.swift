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

  //let p = "PUZ001-1" // "HWV106-1"
  private func parseProblem<N:Node>(problem:String = "HWV106-1") -> [N] {
    let inputs : [N] = demoParse(problem:problem)

    print(problem, "count :", inputs.count)

    guard inputs.count > 0 else { return [N]() }

    print("#1", inputs[0])

    print("Node == \(String(reflecting:N.self))")
    XCTAssertEqual(287949,inputs.count,nok)
    return inputs
  }

  func testSimpleNode() {
    typealias NodeType = Tptp.SimpleNode
    let inputs : [NodeType] = parseProblem()
    XCTAssertEqual(287949,inputs.count,nok)
  }

  func testSharingNode() {
    typealias NodeType = Tptp.SharingNode
    let inputs : [NodeType] = parseProblem()
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.allNodes.count)
  }

  func testSmartNode() {
    typealias NodeType = Tptp.SmartNode
    let inputs : [NodeType] = parseProblem()
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.allNodes.count,nok)
    XCTAssertEqual(0, NodeType.allNodes.collisionCount,nok)
  }

  func testKinNode() {
    typealias NodeType = Tptp.KinNode
    let inputs : [NodeType] = parseProblem()
    XCTAssertEqual(287949,inputs.count,nok)
    XCTAssertEqual(807725,NodeType.allNodes.count,nok)
    XCTAssertEqual(0, NodeType.allNodes.collisionCount,nok)
  }
}
