import XCTest

@testable import FLEA

/// local minimal implementation of protocol
/// to avoid side effects (pool) from ohter test classes
private final class SmartNode : FLEA.SharingNode, SymbolStringTyped {
  typealias S = FLEA.Tptp.Symbol // choose the symbol

  static var pool = WeakSet<SmartNode>()

  var symbol = S("",.undefined)
  var nodes : [SmartNode]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

private typealias Node = SmartNode // use local implementation

/// Test the accumulation of nodes in SmartNode.pool.
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

    let X = Node(v:"X")
    let a = Node(c:"a")
    let fX = Node(f:"f", [X])
    let fa = Node(f:"f", [a])

    let fX_a = fX * [Node(v:"X"):Node(c:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = Node.pool.count
    XCTAssertEqual(count,4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")


  }

  /// accumulate four distict nodes
  func testEqualityY() {

    let X = Node(v:"Y")
    let a = Node(c:"a")
    let fX = Node(f:"f", [X])
    let fa = Node(f:"f", [a])

    let fX_a = fX * [Node(v:"Y"):Node(c:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)

    let count = Node.pool.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")




  }
}
