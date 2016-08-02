import XCTest

@testable import FLEA

/// local minimal implementation of protocol
/// to avoid side effects (pool) from ohter test classes
private final class IntNode : FLEA.KinNode {
  typealias S = Int // choose the symbol

  static var pool = WeakSet<IntNode>()

  var symbol = S.empty
  var nodes : [IntNode]? = nil

  var folks = WeakSet<IntNode>()

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

private typealias Node = IntNode  // use local implementation

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class NodePathsTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (NodePathsTests) -> () throws -> Void)]  {
    return [
      ("testNodePaths", testNodePaths)
    ]
  }

  /// accumulate four distict nodes
  func testNodePaths() {

    let X = Node(v:"X")
    let a = Node(c:"a")
    let fX = Node(f:"f", [X])
    let fa = Node(f:"f", [a])
    let gfXfa = Node(f:"g", [fX,fa])
    let ggfXfaX = Node(f:"g", [gfXfa,X])

    let _f = fX.symbol
    let _g = gfXfa.symbol
    let _ü = Int("*",.variable)
    let _a = a.symbol

    let count = Node.pool.count
    XCTAssertEqual(count,6, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

    XCTAssertEqual(
      [
        [_g,0,_g,0,_f,0,_ü],
        [_g,0,_g,1,_f,0,_a],
        [_g,1,_ü]
        ],
      ggfXfaX.leafPaths
    )

    XCTAssertEqual(
      [_g,_g,_f,_ü,_f,_a,_ü],
      ggfXfaX.prefixPath
    )



  }
}
