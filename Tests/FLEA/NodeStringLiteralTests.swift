import XCTest

@testable import FLEA


private typealias Node = FLEA.Tptp.SimpleNode

extension Node : StringLiteralConvertible {

}



/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class NodeStringLiteralTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (NodeStringLiteralTests) -> () throws -> Void)]  {
    return [
      ("testStringLiterals", testStringLiterals)
    ]
  }

  /// accumulate four distict nodes
  func testStringLiterals() {
    let a : Node = "a"
    print(a)
  }


}
