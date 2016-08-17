import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class NodePathsTests : XCTestCase {
  /// local minimal implementation of protocol
  /// to avoid side effects (pool) from ohter test classes
  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node  {
    static var pool = WeakSet<N>()
    static var symbols = StringIntegerTable<Int>()
    
    var symbol = Int.max
    var nodes : [N]? = nil
    
    var folks = WeakSet<N>()
    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
    deinit {
      print("\(#function) \(self)")
    }
  }
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (NodePathsTests) -> () throws -> Void)]  {
    return [
      ("testNodePaths", testNodePaths)
    ]
  }

  /// accumulate four distict nodes
  func testNodePaths() {

    let X = N(v:"X")
    let a = N(c:"a")
    let fX = N(f:"f", [X])
    let fa = N(f:"f", [a])
    let gfXfa = N(f:"g", [fX,fa])
    let ggfXfaX = N(f:"g", [gfXfa,X])

    let f$ = fX.symbol
    let g$ = gfXfa.symbol
    let _$ = N.symbols.insert("*",.variable)
    let a$ = a.symbol

    let count = N.pool.count
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
