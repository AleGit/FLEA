import XCTest

@testable import FLEA

public class DescriptionTests: FleaTestCase {

  static var allTests: [(String, (DescriptionTests) -> () throws -> Void)] {
    return [
      ("testDescription", testDescription),
      ("testDebugDescription", testDebugDescription)
    ]
  }

  // local private adoption of protocol to avoid any side affects
  private final class N: SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node {
    typealias S = Int
    static var symbols = StringIntegerTable<S>()
    static var pool = WeakSet<N>()
    var folks =  WeakSet<N>()

    var symbol: S = N.symbolize(string:"*", type:.variable)
    var nodes: [N]? = nil

    lazy var description: String = self.defaultDescription
  }

  func testDescription() {
    let a = N(c:"a")
    let X = N(v:"X")
    let fXa = N(f:"f", [X, a])

    XCTAssertEqual("a", a.description, nok)
    XCTAssertEqual("X", X.description, nok)

    XCTAssertEqual("f(X,a)", fXa.description, nok)
  }

  func testDebugDescription() {
    let a = N(c:"a")
    let X = N(v:"X")
    let fXa = N(f:"f", [X, a])

    let equals = N.symbolize(string:"=", type:.equation)
    let a_X = N(symbol: equals, nodes: [a, X])

    XCTAssertEqual("1-a-function(0)", a.debugDescription, nok)
    XCTAssertEqual("-3-X-variable", X.debugDescription, nok)

    XCTAssertEqual("4-f-function(2)(-3-X-variable,1-a-function(0))", fXa.debugDescription, nok)

    XCTAssertEqual("5-=-equation(1-a-function(0),-3-X-variable)", a_X.debugDescription, nok)

    XCTAssertEqual("a", a.description, nok)
    XCTAssertEqual("X", X.description, nok)
    XCTAssertEqual("f(X,a)", fXa.description, nok)
    XCTAssertEqual("a=X", a_X.description, nok)
  }
}
