import XCTest

@testable import FLEA

private final class SmartNode : FLEA.SmartNode {
  typealias S = String

  static var allNodes = WeakSet<SmartNode>()

  var symbol = S.empty
  var nodes : [SmartNode]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

private typealias Node = SmartNode

/// Test the accumulation of nodes in SmartNode.allNodes.
/// Nodes MUST NOT accumulate between tests.
public class SmartNodeTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (SmartNodeTests) -> () throws -> Void)]  {
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

    let fX_a = fX * [Node(variable:"X"):Node(constant:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

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

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = Node.allNodes.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")




  }
}
