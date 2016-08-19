import XCTest

@testable import FLEA

public class NodeTests : FleaTestCase {
  static var allTests : [(String,(NodeTests) -> () throws -> Void)] {
    return [
    ("testInit",testInit)
    ]
  }

  // local private adoption of protocol to avoid any side affects
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
