import XCTest

@testable import FLEA

public class NodeTests : XCTestCase {
  static var allTests : [(String,(NodeTests) -> () throws -> Void)] {
    return [
    ("testInit",testInit)
    ]
  }

  // minimal adoption of protocol FLEA.Node
  private struct Node : FLEA.Node {
    var symbol : String = ""
    var nodes : [Node]? = nil
  }

  func testInit() {
    let a = Node(constant:"a")
    let X = Node(variable:"X")
    let faX = Node(symbol:"f",nodes:[a,X])
    XCTAssertEqual("f(a,X)", faX.description)
  }
}
