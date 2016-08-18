import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class StringLiteralTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (StringLiteralTests) -> () throws -> Void)]  {
    return [
      ("testAnnotations", testAnnotations),
      ("testHeuristics", testHeuristics),
      ("testUndefined", testUndefined)
    ]
  }


// local private adoption of protocol to avoid any side affects
  private final class N : SymbolStringTyped, Node, ExpressibleByStringLiteral {
  typealias S = Tptp.Symbol
  
  var symbol : S = N.symbolize(string:"*", type:.variable)
  var nodes : [N]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription
}


  func testAnnotations() {
    let pfX : N = "p(f(X))"
    XCTAssertEqual(pfX.symbol.type, .function(1))
    XCTAssertEqual("p(f(X))", pfX.description, nok)

    let fof : N = "@fof p(f(X))"
    XCTAssertEqual(fof.symbol.type,.predicate(1),"\(nok) fof :: \(fof)")
    XCTAssertEqual("p(f(X))", fof.description,nok)

    let cnf : N = "@cnf p(f(X))" // =>
    XCTAssertEqual(cnf.symbol.type,.disjunction,"\(nok) cnf :: \(cnf)")
    XCTAssertEqual(cnf.nodes!.first!.symbol.type,.predicate(1),"\(nok) cnf :: \(cnf)")
    XCTAssertEqual("(p(f(X)))", cnf.description,nok)

    let fofp : N = "@fof p(f(X))"
    XCTAssertEqual(fofp.symbol.type,.predicate(1),"\(nok) fofp :: \(fofp)")
    XCTAssertEqual("p(f(X))", fofp.description,nok)

    let fofn : N = "@fof ~p(f(X))"
    XCTAssertEqual(fofn.symbol.type,.negation,"\(nok) fofn :: \(fofn)")
    XCTAssertEqual(fofn.nodes!.first!.symbol.type,.predicate(1),"\(nok) fofn :: \(fofn)")
    XCTAssertEqual("~(p(f(X)))", fofn.description,nok)

    let fofe : N = "@fof p=X"
    XCTAssertEqual(fofe.symbol.type,.equation,"\(nok) fofe :: \(fofe)")
    XCTAssertEqual("p=X", fofe.description,nok)

    let clause : N = "@cnf ~p(f(X))"
    XCTAssertEqual(clause.symbol.type,.disjunction,"\(nok) clause :: \(clause)")
    XCTAssertEqual("(~(p(f(X))))", clause.description,nok)
  }

  func testHeuristics() {
    let a : N = "a"
    XCTAssertEqual(a.symbol.type,.function(0),"\(nok) a :: \(a)")
    XCTAssertEqual("a", a.description,nok)

    let X : N = "X"
    XCTAssertEqual(X.symbol.type,.variable,"\(nok) X :: \(X)")
    XCTAssertEqual("X", X.description,nok)

    let fX : N = "f(X)"
    XCTAssertEqual(fX.symbol.type,.function(1),"\(nok) fX :: \(fX)")
    XCTAssertEqual("f(X)", fX.description,nok)

    let equal : N = "a=X"
    XCTAssertEqual(equal.symbol.type,.equation,"\(nok) equal :: \(equal)")
    XCTAssertEqual("a=X", equal.description,nok)

    let neq : N = "a!=X"
    XCTAssertEqual(neq.symbol.type,.inequation,"\(nok) neq :: \(neq)")
    XCTAssertEqual("a!=X", neq.description,nok)

    let not : N = "~p(f(X))"
    XCTAssertEqual(not.symbol.type,.negation,"\(nok) not :: \(not)")
    XCTAssertEqual("~(p(f(X)))", not.description,nok)

    let dis : N = "p|q"
    XCTAssertEqual(dis.symbol.type,.disjunction,"\(nok) dis :: \(dis)")
    XCTAssertEqual("(p|q)", dis.description,nok)

    let con : N = "p&q"
    XCTAssertEqual(con.symbol.type,.conjunction,"\(nok) con :: \(con)")
    XCTAssertEqual("(p&q)", con.description,nok)

    let impl : N = "p=>q"
    // XCTAssertEqual(impl.symbol.type,.implication,"\(nok) impl :: \(impl)")
    XCTAssertEqual("(p=>q)", impl.description,nok)

  }

  func testUndefined() {
    let ab : N = "@cnf a&b" // =>
    // XCTAssertEqual(ab.symbol.type,.function(2),"\(nok) ab :: \(ab)")
    XCTAssertEqual("@cnf a&b ❌ .parse error",ab.description)

  }


}
