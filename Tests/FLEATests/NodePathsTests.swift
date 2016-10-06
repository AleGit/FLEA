import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class NodePathsTests : FleaTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (NodePathsTests) -> () throws -> Void)]  {
    return [
      ("testNodePaths", testNodePaths),
      ("testNegatedPaths",testNegatedPaths)
    ]
  }

  // local private adoption of protocol to avoid any side affects
  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node,
  ExpressibleByStringLiteral  {
    typealias S = Int
    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()

    var symbol : S = N.symbolize(string:"*",type:.variable)
    var nodes : [N]? = nil

    deinit {
      print("\(#function) \(self)")
    }

    var description : String {
      return defaultDescription
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
      [g$,0,g$,0,f$,0,-1],
      [g$,0,g$,1,f$,0,a$],
      [g$,1,-1]
      ]
    let actual = ggfXfaX.leafPaths
    XCTAssertEqual(
        expected.count,
        actual.count,
        nok
      )
    XCTAssertEqual(
        Array(expected.joined()),
        Array(actual.joined()),
        nok
      )

// #endif
    XCTAssertEqual(
      [g$,g$,f$,_$,f$,a$,_$],
      ggfXfaX.preorderTraversalSymbols, nok
    )
  }

  func testNegatedPaths() {
    let pfx : N = "@fof p(f(X))" // p is predicate
    let npfx : N = "~p(f(X))"
    let a_X : N = "a = X"
    let a_n_X : N = "a != X"

    var expected = pfx.leafPathsPair.0
    var actual = npfx.leafPathsPair.1



    XCTAssertEqual(
      Array(expected.joined()),
      Array(actual.joined())
    )

    expected = npfx.leafPathsPair.0
    actual = pfx.leafPathsPair.1

    XCTAssertEqual(
      Array(expected.joined()),
      Array(actual.joined())
    )



    expected = a_X.leafPathsPair.0
    actual = a_n_X.leafPathsPair.1

    XCTAssertEqual(
      Array(expected.joined()),
      Array(actual.joined()),
      "\(a_X) \(a_n_X)"
    )

    expected = a_n_X.leafPathsPair.0
    actual = a_X.leafPathsPair.1

    XCTAssertEqual(
      Array(expected.joined()),
      Array(actual.joined()),
      "\(a_n_X) \(a_X)"
    )

  }


}
