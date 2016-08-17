import XCTest

@testable import FLEA

/// Test the accumulation of nodes in N.pool.
/// Nodes MUST NOT accumulate between tests.
public class SmartNodeTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (SmartNodeTests) -> () throws -> Void)]  {
    return [
      ("testEqualityX", testEqualityX),
      ("testEqualityY", testEqualityY)
    ]
  }

  /// local minimal implementation of protocol
/// to avoid side effects (pool) from ohter test classes
private final class N : SymbolStringTyped, Sharing, Node  {
  typealias S = Tptp.Symbol // choose the symbol

  static var pool = WeakSet<N>()

  var symbol = S("",.undefined)
  var nodes : [N]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

  /// accumulate four distict nodes
  func testEqualityX() {

    let X = N(v:"X")
    let a = N(c:"a")
    let fX = N(f:"f", [X])
    let fa = N(f:"f", [a])

    let fX_a = fX * [N(v:"X"):N(c:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)
    XCTAssertTrue(fX.nodes!.first! == X)
    XCTAssertTrue(fa.nodes!.first! == a)

    let count = N.pool.count
    XCTAssertEqual(count,4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

    let ffa = N(f:"f", [ N(f:"f",[N(v:"Y")])]) * [ N(v:"Y") : N(c:"a")]
    XCTAssertEqual(5, N.pool.count, "\(nok)  \(#function) \(count) ≠ 5 smart nodes accumulated.")
    let g = fX * [ X: fa]
    XCTAssertEqual(5, N.pool.count, "\(nok)  \(#function) \(count) ≠ 5 smart nodes accumulated.")
    XCTAssertTrue(ffa == g)

    XCTAssertFalse( N.pool.one { $0.symbolStringType.0 == "Y" } ) /// Y must not be stored
  }

  /// accumulate four distict nodes
  func testEqualityY() {

    let X = N(v:"Y")
    let a = N(c:"a")
    let fX = N(f:"f", [X])
    let fa = N(f:"f", [a])

    let fX_a = fX * [N(v:"Y"):N(c:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = N.pool.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")




  }
}
