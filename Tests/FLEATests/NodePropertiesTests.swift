import XCTest

@testable import FLEA

public class NodePropertiesTests: FleaTestCase {
    typealias T = NodePropertiesTests

  static var allTests: [(String, (NodePropertiesTests) -> () throws -> Void)] {
    return [
    ("testInit", testHeight),
    ("testWidth", testWidth),
    ("testSize", testSize),
    ("testSharing", testSharing),
    ("testKin", testKin),
    ("testHashValue", testHashValue),
    ("testDescription", testDescription)
    ]
  }

  override class public func setUp() {
      super.setUp() // carping is off
      Syslog.carping = true // carping is on
  }

  // local private adoption of protocol to avoid any side affects
  private final class FullNode: SymbolStringTyped, SymbolTabulating,
  Sharing, Kin, Node, ExpressibleByStringLiteral {
    static var symbols = StringIntegerTable<Int>()  // : SymbolTabulating
    static var pool = WeakSet<FullNode>()                  // : Sharing
    var folks =  WeakSet<FullNode>()                       // : Kin

    var symbol: Int = FullNode.symbolize(string:"*", type:.variable)       // : Node
    var nodes: [FullNode]? = nil                                           // : Node

    // lazy evaluation and memorizing of node properties

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription

    lazy var height: Int = self.defaultHeight
    lazy var width: Int = self.defaultWidth
    lazy var size: Int = self.defaultSize

    // test terms


    static let a = "a" as FullNode
    static let X = "X" as FullNode
    static let faX = "f(a,X)" as FullNode
    static let f2 = "f(g(X),f(a,g(b)))" as FullNode
    static let clause = "p(X)|q(a)" as FullNode

    static let _a = "a" as FullNode
    static let _X = "X" as FullNode
    static let _faX = "f(a,X)" as FullNode
    static let _f2 = "f(g(X),f(a,g(b)))" as FullNode
  }

  func testHeight() {
    XCTAssertEqual(0, FullNode.a.height, nok)
    XCTAssertEqual(0, FullNode.X.height, nok)
    XCTAssertEqual(1, FullNode.faX.height, nok)
  }

  func testWidth() {
    XCTAssertEqual(1, FullNode.a.width, nok)
    XCTAssertEqual(1, FullNode.X.width, nok)
    XCTAssertEqual(2, FullNode.faX.width, nok)
  }

  func testSize() {
    XCTAssertEqual(1, FullNode.a.size, nok)
    XCTAssertEqual(1, FullNode.X.size, nok)
    XCTAssertEqual(3, FullNode.faX.size, nok)
  }

  func testSharing() {
      XCTAssertTrue(FullNode.a === FullNode._a, nok)
      XCTAssertTrue(FullNode.X === FullNode._X, nok)
      XCTAssertTrue(FullNode.faX === FullNode._faX, nok)

      XCTAssertTrue(FullNode.a === FullNode.faX.nodes!.first!, nok)
      XCTAssertTrue(FullNode.X === FullNode.faX.nodes!.last!, nok)

      XCTAssertTrue(FullNode.a === FullNode.f2.nodes!.last!.nodes!.first!, nok)
      XCTAssertTrue(FullNode.X === FullNode.f2.nodes!.first!.nodes!.first!, nok)

      XCTAssertTrue(FullNode.f2 === FullNode._f2, nok)
  }

  func testKin() {
      let _ = [FullNode.a, FullNode.X, FullNode.faX, FullNode.f2, FullNode.clause]

      var expected: [FullNode] = [ FullNode.faX, "f(a,g(b))", FullNode.clause.nodes!.last! ]
      XCTAssertEqual(Set(expected), Set(FullNode.a.folks), nok)

      expected = [ FullNode.faX, "g(X)", FullNode.clause.nodes!.first! ]
      XCTAssertEqual(Set(expected), Set(FullNode.X.folks), nok)

      expected = [FullNode]()
      XCTAssertEqual(Set(expected), Set(FullNode.faX.folks), nok)

      expected = [FullNode]()
      XCTAssertEqual(Set(expected), Set(FullNode.f2.folks), nok)

      expected = [ FullNode.f2 ]
      XCTAssertEqual(Set(expected), Set(("g(X)" as FullNode).folks), nok)
      XCTAssertEqual(Set(expected), Set(("f(a,g(b))" as FullNode).folks), nok)

      expected = [ FullNode.faX, "f(a,g(b))", "g(a)", FullNode.clause.nodes!.last!]
      XCTAssertEqual(Set(expected), Set(FullNode.a.folks), nok)

      expected = [ "g(f(a,X))" ]
      XCTAssertEqual(Set(expected), Set(FullNode.faX.folks), nok)
  }

  func testHashValue() {

      XCTAssertEqual(FullNode.faX.hashValue, FullNode.faX.defaultHashValue, nok)

      XCTAssertNotEqual(FullNode.a.hashValue, FullNode.X.hashValue, nok)
      XCTAssertNotEqual(FullNode.a.hashValue, FullNode.faX.hashValue, nok)
      XCTAssertNotEqual(FullNode.a.hashValue, FullNode.f2.hashValue, nok)

      XCTAssertNotEqual(FullNode.X.hashValue, FullNode.faX.hashValue, nok)
      XCTAssertNotEqual(FullNode.X.hashValue, FullNode.f2.hashValue, nok)

      XCTAssertNotEqual(FullNode.faX.hashValue, FullNode.f2.hashValue, nok)
  }

  func testDescription() {
      XCTAssertEqual("f(a,X)", FullNode.faX.defaultDescription, nok)
      XCTAssertEqual("f(g(X),f(a,g(b)))", FullNode.f2.defaultDescription, nok)
      XCTAssertEqual(FullNode.faX.description, FullNode.faX.defaultDescription, nok)

  }
}