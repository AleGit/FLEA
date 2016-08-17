import XCTest

@testable import FLEA

/// local minimal implementation of protocol
/// to avoid side effects (pool) from ohter test classes
private final class KinNode : FLEA.KinNode, SymbolStringTyped,StringSymbolTabulating, ExpressibleByStringLiteral {
  typealias S = UInt32 // choose the symbol

  static var pool = WeakSet<KinNode>()
  static var symbols = StringIntegerTable<S>()

  var symbol = S.max
  var nodes : [KinNode]? = nil

  var folks = WeakSet<KinNode>()

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  // deinit {
  //   print("\(#function) \(self)")
  // }

  static func insert(string:String, type:Tptp.SymbolType) -> UInt32 {
    return 0
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

    let X : Node = "X"
    let a : Node = "a"
    let fX = "f(X)" as Node
    let fa = "f(a)" as Node

    XCTAssertEqual("5-X-variable",X.debugDescription,nok)
    XCTAssertEqual("6-a-function(0)",a.debugDescription,nok)
    XCTAssertEqual("7-f-function(1)(5-X-variable)",fX.debugDescription,nok)
    XCTAssertEqual("7-f-function(1)(6-a-function(0))",fa.debugDescription,nok)

    // check if folks are set correctly

    XCTAssertTrue(X.folks.contains(fX),"\(nok)\n \(X.folks)")
    XCTAssertFalse(X.folks.contains(fa),"\(nok)\n \(X.folks)")
    XCTAssertTrue(a.folks.contains(fa),"\(nok)\n \(a.folks)")
    XCTAssertFalse(a.folks.contains(fX),"\(nok)\n \(a.folks)")

    let fX_a = fX * [Node(v:"X"):Node(c:"a")]


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

    let X = Node(v:"Y")
    let a = Node(c:"a")
    let fX = Node(f:"f", [X])
    let fa = Node(f:"f", [a])

    let fX_a = fX * [Node(v:"Y"):Node(c:"a")]

    XCTAssertEqual(fX_a,fa,nok)
    XCTAssertTrue(fX_a == fa,nok)
    XCTAssertTrue(fX_a === fa,nok)

    let count = Node.pool.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")




  }
}
