import XCTest

@testable import FLEA

/// local minimal implementation of protocol
private final class KinNode : FLEA.KinNode {
  typealias S = String // choose the symbol

  static var pool = WeakSet<KinNode>()

  var symbol = S.empty
  var nodes : [KinNode]? = nil

  var folks = WeakSet<KinNode>()

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

private typealias Node = KinNode  // use local implementation

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class KinNodeTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (KinNodeTests) -> () throws -> Void)]  {
    return [
      ("testEqualityX", testEqualityX),
      ("testEqualityY", testEqualityY)
    ]
  }

  /// accumulate four distict nodes
  func testEqualityX() {

    let X = Node(variable:"X")
    let a = Node(constant:"a")
    let fX = Node(symbol:"f", nodes:[X])
    let fa = Node(symbol:"f", nodes:[a])

    // check if folks are set correctly

    XCTAssertTrue(X.folks.contains(fX),"\(nok)\n \(X.folks)")
    XCTAssertFalse(X.folks.contains(fa),"\(nok)\n \(X.folks)")
    XCTAssertTrue(a.folks.contains(fa),"\(nok)\n \(a.folks)")
    XCTAssertFalse(a.folks.contains(fX),"\(nok)\n \(a.folks)")

    let fX_a = fX * [Node(variable:"X"):Node(constant:"a")]

    // check if subtistuion sets folks correctly

    XCTAssertTrue(a.folks.contains(fX_a),"\(nok)\n \(a.folks)")
    XCTAssertFalse(X.folks.contains(fX_a),"\(nok)\n \(a.folks)")

    XCTAssertEqual(fX_a,fa,nok)
    XCTAssertTrue(fX_a == fa,nok)
    XCTAssertTrue(fX_a === fa,nok)

    let count = Node.pool.count
    XCTAssertEqual(count,4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

  }

  /// accumulate four distict nodes
  func testEqualityY() {

    let X = Node(variable:"Y")
    let a = Node(constant:"a")
    let fX = Node(symbol:"f", nodes:[X])
    let fa = Node(symbol:"f", nodes:[a])

    let fX_a = fX * [Node(variable:"Y"):Node(constant:"a")]

    XCTAssertEqual(fX_a,fa,nok)
    XCTAssertTrue(fX_a == fa,nok)
    XCTAssertTrue(fX_a === fa,nok)

    let count = Node.pool.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")




  }
}
