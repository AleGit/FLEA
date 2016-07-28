import XCTest

@testable import FLEA

/// local minimal implementation of protocol
/// to avoid side effects (pool) from ohter test classes
private final class SharingNode : FLEA.SharingNode {
  typealias S = String

  static var pool = Set<SharingNode>()

  var symbol = S.empty
  var nodes : [SharingNode]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

private typealias Node = SharingNode // use local implementation

/// Test the accumulation of nodes in Q.SharingNode.pool.
/// Nodes MAY accumulate between tests.
public class SharingNodeTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (SharingNodeTests) -> () throws -> Void)]  {
    return [
      ("testEqualityX", testEqualityX),
      ("testEqualityY", testEqualityY)
    ]
  }

  /// accumulate additional four distict nodes
  func testEqualityX() {

    let X = Node(variable:"X")
    let a = Node(constant:"a")
    let fX = Node(symbol:"f", nodes:[X])
    let fa = Node(symbol:"f", nodes:[a])

    let fX_a = fX * [Node(variable:"X"):Node(constant:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = Node.pool.count
    XCTAssertTrue(count >= 4, "\(nok)  \(#function) Just \(count) < 4 sharing nodes accumulated.")

    if count > 4 {
      print("\(ok)  \(#function) \(count) sharing nodes accumulated between tests.")
    }

  }

  /// accumulate additional four distict nodes
  func testEqualityY() {

    let X = Node(variable:"Y")
    let a = Node(constant:"a")
    let fX = Node(symbol:"f", nodes:[X])
    let fa = Node(symbol:"f", nodes:[a])

    let fX_a = fX * [Node(variable:"Y"):Node(constant:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = Node.pool.count
    XCTAssertTrue(count >= 4, "\(nok)  \(#function) Just \(count) < 4 sharing nodes accumulated.")

    if count > 4 {
      print("\(ok)  \(#function) \(count) sharing nodes accumulated between tests.")
    }
  }



}
