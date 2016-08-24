import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class KinNodeTests : FleaTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (KinNodeTests) -> () throws -> Void)]  {
    return [
      ("testEqualityX", testEqualityX),
      ("testEqualityY", testEqualityY)
    ]
  }

  // local private adoption of protocol to avoid any side affects
  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node, ExpressibleByStringLiteral {
    typealias S = Int
    static var symbols = StringIntegerTable<S>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()
    
    var symbol : S = N.symbolize(string:Tptp.asterisk, type:.variable)
    var nodes : [N]? = nil
  }

  /// accumulate four distict nodes
  func testEqualityX() {
    let symbol = N.symbolize(string:"*", type:.variable) 
    XCTAssertEqual(1,symbol)  

    let X : N = "X"
    let a : N = "a"
    let fX = "f(X)" as N
    let fa = "f(a)" as N

    XCTAssertEqual("6-X-variable",X.debugDescription,nok)
    XCTAssertEqual("7-a-function(0)",a.debugDescription,nok)
    XCTAssertEqual("8-f-function(1)(6-X-variable)",fX.debugDescription,nok)
    XCTAssertEqual("8-f-function(1)(7-a-function(0))",fa.debugDescription,nok)

    // check if folks are set correctly

    XCTAssertTrue(X.folks.contains(fX),"\(nok)\n \(X.folks)")
    XCTAssertFalse(X.folks.contains(fa),"\(nok)\n \(X.folks)")
    XCTAssertTrue(a.folks.contains(fa),"\(nok)\n \(a.folks)")
    XCTAssertFalse(a.folks.contains(fX),"\(nok)\n \(a.folks)")

    let fX_a = fX * [N(v:"X"):N(c:"a")]


    // check if subtistuion sets folks correctly

    XCTAssertTrue(a.folks.contains(fX_a),"\(nok)\n \(a.folks)")
    XCTAssertFalse(X.folks.contains(fX_a),"\(nok)\n \(a.folks)")

    XCTAssertEqual(fX_a,fa,nok)
    XCTAssertTrue(fX_a == fa,nok)
    XCTAssertTrue(fX_a === fa,nok)

    let count = N.pool.count
    XCTAssertEqual(count,4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

  }

  /// accumulate four distict nodes
  func testEqualityY() {

    let X = N(v:"Y")
    let a = N(c:"a")
    let fX = N(f:"f", [X])
    let fa = N(f:"f", [a])

    let fX_a = fX * [N(v:"Y"):N(c:"a")]

    XCTAssertEqual(fX_a,fa,nok)
    XCTAssertTrue(fX_a == fa,nok)
    XCTAssertTrue(fX_a === fa,nok)

    let count = N.pool.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")
  }
}
