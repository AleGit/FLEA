import XCTest

@testable import FLEA

public class NodePropertiesTests: FleaTestCase {
    typealias T = NodePropertiesTests

  static var allTests: [(String, (NodePropertiesTests) -> () throws -> Void)] {
    return [
    ("testInit", testHeight)
    ]
  }

  override class public func setUp() {
      super.setUp() // carping is off
      Syslog.carping = true // carping is on
  }

  // local private adoption of protocol to avoid any side affects
  final class N: SymbolStringTyped, SymbolTabulating, Sharing, Node, ExpressibleByStringLiteral {
    static var symbols = StringIntegerTable<Int>()  // : SymbolTabulating
    static var pool = WeakSet<N>()                  // : Sharing
    // var folks =  WeakSet<N>()                    // : Kin

    var symbol: Int = N.symbolize(string:"*", type:.variable)       // : Node
    var nodes: [N]? = nil                                           // : Node

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
    lazy var height: Int = self.defaultHeight


    static let a = "a" as N
    static let X = "X" as N
    static let faX = "f(a,X)" as N
  }

  func testHeight() {

    let value = Syslog.carping
    Syslog.carping = true
    defer { Syslog.carping = value }

    XCTAssertEqual(0, N.a.height, nok)
    XCTAssertEqual(0, N.X.height, nok)
    XCTAssertEqual(1, N.faX.height, nok)
  }

  func testHashValue() {
      XCTAssertEqual(N.faX.hashValue, N.faX.defaultHashValue, nok)
  }

  func testDescription() {
      XCTAssertEqual(N.faX.description, N.faX.defaultDescription, nok)

  }
}