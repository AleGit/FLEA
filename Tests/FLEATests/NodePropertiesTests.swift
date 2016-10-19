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
  final class N: SymbolStringTyped, SymbolTabulating,
  Sharing, Kin, Node, ExpressibleByStringLiteral {
    static var symbols = StringIntegerTable<Int>()  // : SymbolTabulating
    static var pool = WeakSet<N>()                  // : Sharing
    var folks =  WeakSet<N>()                       // : Kin

    var symbol: Int = N.symbolize(string:"*", type:.variable)       // : Node
    var nodes: [N]? = nil                                           // : Node

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription

    lazy var height: Int = self.defaultHeight
    lazy var width: Int = self.defaultWidth
    lazy var size: Int = self.defaultSize


    static let a = "a" as N
    static let X = "X" as N
    static let faX = "f(a,X)" as N
    static let f2 = "f(g(X),f(a,g(b)))" as N

    static let _a = "a" as N
    static let _X = "X" as N
    static let _faX = "f(a,X)" as N
    static let _f2 = "f(g(X),f(a,g(b)))" as N
  }

  func testHeight() {
    XCTAssertEqual(0, N.a.height, nok)
    XCTAssertEqual(0, N.X.height, nok)
    XCTAssertEqual(1, N.faX.height, nok)
  }

  func testWidth() {
    XCTAssertEqual(1, N.a.width, nok)
    XCTAssertEqual(1, N.X.width, nok)
    XCTAssertEqual(2, N.faX.width, nok)
  }

  func testSize() {
    XCTAssertEqual(1, N.a.size, nok)
    XCTAssertEqual(1, N.X.size, nok)
    XCTAssertEqual(3, N.faX.size, nok)
  }

  func testSharing() {
      XCTAssertTrue(N.a === N._a, nok)
      XCTAssertTrue(N.X === N._X, nok)
      XCTAssertTrue(N.faX === N._faX, nok)

      XCTAssertTrue(N.a === N.faX.nodes!.first!, nok)
      XCTAssertTrue(N.X === N.faX.nodes!.last!, nok)

      XCTAssertTrue(N.a === N.f2.nodes!.last!.nodes!.first!, nok)
      XCTAssertTrue(N.X === N.f2.nodes!.first!.nodes!.first!, nok)

      XCTAssertTrue(N.f2 === N._f2, nok)
  }

  func testKin() {
      let _ = [N.a, N.X, N.faX, N.f2]

      var expected: [N] = [ N.faX, "f(a,g(b))" ]
      XCTAssertEqual(Set(expected), Set(N.a.folks), nok)

      expected = [ N.faX, "g(X)" ]
      XCTAssertEqual(Set(expected), Set(N.X.folks), nok)

      expected = [N]()
      XCTAssertEqual(Set(expected), Set(N.faX.folks), nok)

      expected = [N]()
      XCTAssertEqual(Set(expected), Set(N.f2.folks), nok)

      expected = [ N.f2 ]
      XCTAssertEqual(Set(expected), Set(("g(X)" as N).folks), nok)
      XCTAssertEqual(Set(expected), Set(("f(a,g(b))" as N).folks), nok)

      expected = [ N.faX, "f(a,g(b))", "g(a)" ]
      XCTAssertEqual(Set(expected), Set(N.a.folks), nok)

      expected = [ "g(f(a,X))"]
      XCTAssertEqual(Set(expected), Set(N.faX.folks), nok)
  }

  func testHashValue() {

      XCTAssertEqual(N.faX.hashValue, N.faX.defaultHashValue, nok)

      XCTAssertNotEqual(N.a.hashValue, N.X.hashValue, nok)
      XCTAssertNotEqual(N.a.hashValue, N.faX.hashValue, nok)
      XCTAssertNotEqual(N.a.hashValue, N.f2.hashValue, nok)

      XCTAssertNotEqual(N.X.hashValue, N.faX.hashValue, nok)
      XCTAssertNotEqual(N.X.hashValue, N.f2.hashValue, nok)

      XCTAssertNotEqual(N.faX.hashValue, N.f2.hashValue, nok)
  }

  func testDescription() {
      XCTAssertEqual("f(a,X)", N.faX.defaultDescription, nok)
      XCTAssertEqual("f(g(X),f(a,g(b)))", N.f2.defaultDescription, nok)
      XCTAssertEqual(N.faX.description, N.faX.defaultDescription, nok)

  }
}