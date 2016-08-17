import XCTest

@testable import FLEA

/// Test the accumulation of nodes in Q.N.pool.
/// Nodes MAY accumulate between tests.
public class SharingNodeTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (SharingNodeTests) -> () throws -> Void)]  {
    return [
      ("testEqualityX", testEqualityX),
      ("testEqualityY", testEqualityY)
    ]
  }

  /// local minimal implementation of protocol
/// to avoid side effects (pool) from other test classes
private final class N : SymbolStringTyped, Sharing, Node {
  typealias S = Tptp.Symbol

  static var pool = Set<N>()

  var symbol = S("",.undefined)
  var nodes : [N]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

  /// accumulate additional four distict nodes
  func testEqualityX() {

    let X = N(v:"X")
    let a = N(c:"a")
    let fX = N(f:"f", [X])
    let fa = N(f:"f", [a])

    let fX_a = fX * [N(v:"X"):N(c:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = N.pool.count
    XCTAssertTrue(count >= 4, "\(nok)  \(#function) Just \(count) < 4 sharing nodes accumulated.")

    if count > 4 {
      print("\(ok)  \(#function) \(count) sharing nodes accumulated between tests.")
    }

  }

  /// accumulate additional four distict nodes
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
    XCTAssertTrue(count >= 4, "\(nok)  \(#function) Just \(count) < 4 sharing nodes accumulated.")

    if count > 4 {
      print("\(ok)  \(#function) \(count) sharing nodes accumulated between tests.")
    }
  }



}
