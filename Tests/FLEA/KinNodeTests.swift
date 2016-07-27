import XCTest

@testable import FLEA

private final class KinNode : FLEA.KinNode {
  typealias S = String // choose the symbol

  static var allNodes = WeakSet<KinNode>()

  var symbol = S.empty
  var nodes : [KinNode]? = nil

  var parents = WeakSet<KinNode>()

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

private typealias Node = FLEA.Tptp.KinNode

/// Test the accumulation of nodes in SmartNode.allNodes.
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

    XCTAssertTrue(X.parents.contains(fX),"\(nok)\n \(X.parents)")
    XCTAssertFalse(X.parents.contains(fa),"\(nok)\n \(X.parents)")
    XCTAssertTrue(a.parents.contains(fa),"\(nok)\n \(a.parents)")
    XCTAssertFalse(a.parents.contains(fX),"\(nok)\n \(a.parents)")

    let fX_a = fX * [Node(variable:"X"):Node(constant:"a")]

    XCTAssertTrue(a.parents.contains(fX_a),"\(nok)\n \(a.parents)")
    XCTAssertFalse(X.parents.contains(fX_a),"\(nok)\n \(a.parents)")

    XCTAssertEqual(fX_a,fa,nok)
    XCTAssertTrue(fX_a == fa,nok)
    XCTAssertTrue(fX_a === fa,nok)

    let count = Node.allNodes.count
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

    let count = Node.allNodes.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")




  }
}
