import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class NodePathsTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (NodePathsTests) -> () throws -> Void)]  {
    return [
      ("testNodePaths", testNodePaths)
    ]
  }

  // local private adoption of protocol to avoid any side affects
  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node  {
    typealias S = Int
    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()

    var symbol : S = N.symbolize(string:"*",type:.variable)
    var nodes : [N]? = nil
    
    deinit {
      print("\(#function) \(self)")
    }
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
