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
  private final class LocalNode: SymbolStringTyped, SymbolTabulating, Sharing, Node {
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

  func testF1() {
    let fa = LocalNode(f:"f", [LocalNode(c:"a")])
    XCTAssertEqual("f(a)", fa.description)

    guard let _ = LocalNode.symbols.remove("f") else {
        XCTFail("'f' was not removed from symbol table")
        return
    }

    let faX = LocalNode(f:"f", [LocalNode(c:"a"), LocalNode(v:"X")])
    XCTAssertEqual("f(a,X)", faX.description)
  }

  func testF2() {
    let f = LocalNode(f:"f", [LocalNode(c:"a"), LocalNode(v:"X")])
    XCTAssertEqual("f(a,X)", f.description)
  }
}