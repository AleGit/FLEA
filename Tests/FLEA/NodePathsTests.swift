import XCTest

@testable import FLEA

/// local minimal implementation of protocol
/// to avoid side effects (pool) from ohter test classes
private final class IntNode : FLEA.KinNode, FLEA.HasSymbolTable {
  typealias S = Int // choose the symbol

  static var pool = WeakSet<IntNode>()
  static var symbols = IntegerSymbolTable<S>()

  var symbol = S.max
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

    let f$ = fX.symbol
    let g$ = gfXfa.symbol
    let _$ = Node.symbols.insert("*",.variable)
    let a$ = a.symbol

    let count = Node.pool.count
    XCTAssertEqual(count,6, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

    let expected = [
      [g$,0,g$,0,f$,0,_$],
      [g$,0,g$,1,f$,0,a$],
      [g$,1,_$]
      ]
    let actual = ggfXfaX.leafPaths
#if os(OSX)
    XCTAssertEqual(
      expected,actual, nok
    )
#elseif os(Linux)
  // [[Int]] == [[Int]] does not work on Linux Swift 3P3.
      XCTAssertEqual(
        Array(expected.flatten()),
        Array(actual.flatten()), nok
      )

#endif
    XCTAssertEqual(
      [g$,g$,f$,_$,f$,a$,_$],
      ggfXfaX.preordering, nok
    )
  }


}
