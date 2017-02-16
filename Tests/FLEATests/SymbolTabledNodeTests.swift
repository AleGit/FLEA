import XCTest

@testable import FLEA

public class SymbolTabledNodeTests: FleaTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (SymbolTabledNodeTests) -> () throws -> Void)]  {
    return [
      ("testF1", testF1),
      ("testF2", testF2)
    ]
  }// local private adoption of protocol to avoid any side affects
  private final class LocalNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    var symbol: Int = LocalNode.symbolize(string:"*", type:.variable)
    var nodes: [LocalNode]? = nil

    static var pool = Set<LocalNode>()
    static var symbols = StringIntegerTable<Int>()
  }

  override public func tearDown() {
      // clear symbol table after each test, i.e. between tests.
      LocalNode.symbols.clear()
      super.tearDown()
  }

  let key = "f"

  func testF1() {
    let fa = LocalNode(f:key, [LocalNode(c:"a")])
    XCTAssertEqual("f(a)", fa.description)

    guard let _ = LocalNode.symbols.remove(key) else {
        XCTFail("'f' was not removed from symbol table")
        return
    }

    let faX = LocalNode(f:key, [LocalNode(c:"a"), LocalNode(v:"X")])
    XCTAssertEqual("f(a,X)", faX.description, nok)

    XCTAssertEqual(LocalNode.symbols["f"]?.1, FLEA.Tptp.SymbolType.function(2), nok)
  }

  func testF2() {
    let f = "f(f(a,b,c),Y,Z)=g(X)&p(X)" as LocalNode
    XCTAssertEqual("(f(f(a,b,c),Y,Z)=g(X)&p(X))", f.description, nok)
    XCTAssertEqual(LocalNode.symbols["f"]?.1, FLEA.Tptp.SymbolType.function(3), nok)
    XCTAssertEqual(LocalNode.symbols["a"]?.1, FLEA.Tptp.SymbolType.function(0), nok)
    XCTAssertEqual(LocalNode.symbols["b"]?.1, FLEA.Tptp.SymbolType.function(0), nok)
    XCTAssertEqual(LocalNode.symbols["Y"]?.1, FLEA.Tptp.SymbolType.variable, nok)
    XCTAssertEqual(LocalNode.symbols["Z"]?.1, FLEA.Tptp.SymbolType.variable, nok)
    XCTAssertEqual(LocalNode.symbols["X"]?.1, FLEA.Tptp.SymbolType.variable, nok)
    XCTAssertEqual(LocalNode.symbols["p"]?.1, FLEA.Tptp.SymbolType.predicate(1), nok)
    XCTAssertEqual(LocalNode.symbols["&"]?.1, FLEA.Tptp.SymbolType.conjunction, nok)

  }
}
