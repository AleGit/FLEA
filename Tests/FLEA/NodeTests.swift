import XCTest

@testable import FLEA

public class NodeTests : XCTestCase {
  static var allTests : [(String,(NodeTests) -> () throws -> Void)] {
    return [
    ("testInit",testInit)
    ]
  }

  // minimal adoption of protocol FLEA.Node
  private struct N : Node {
    var symbol : String = ""
    var nodes : [N]? = nil
  }

  func testInit() {
    let a = N(constant:"a")
    let X = N(variable:"X")
    let faX = N(symbol:"f",nodes:[a,X])
    XCTAssertEqual("f(a,X)", faX.description)
  }
}
