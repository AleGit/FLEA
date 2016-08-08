import XCTest

@testable import FLEA

private final class StringLiteralNode : FLEA.Node, StringLiteralConvertible {
  var symbol = Tptp.Symbol("",.undefined) // avoid side effects with symbol tables
  var nodes : [StringLiteralNode]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription
}


private typealias Node = StringLiteralNode



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

  func testAnnotations() {
    let pfX : Node = "p(f(X))"
    XCTAssertEqual(pfX.symbol.type, .function(1))
    XCTAssertEqual("p(f(X))", pfX.description, nok)

    let fof : Node = "@fof p(f(X))"
    XCTAssertEqual(fof.symbol.type,.predicate(1),"\(nok) fof :: \(fof)")
    XCTAssertEqual("p(f(X))", fof.description,nok)

    let cnf : Node = "@cnf p(f(X))" // =>
    XCTAssertEqual(cnf.symbol.type,.disjunction,"\(nok) cnf :: \(cnf)")
    XCTAssertEqual(cnf.nodes!.first!.symbol.type,.predicate(1),"\(nok) cnf :: \(cnf)")
    XCTAssertEqual("(p(f(X)))", cnf.description,nok)

    let fofp : Node = "@fof p(f(X))"
    XCTAssertEqual(fofp.symbol.type,.predicate(1),"\(nok) fofp :: \(fofp)")
    XCTAssertEqual("p(f(X))", fofp.description,nok)

    let fofn : Node = "@fof ~p(f(X))"
    XCTAssertEqual(fofn.symbol.type,.negation,"\(nok) fofn :: \(fofn)")
    XCTAssertEqual(fofn.nodes!.first!.symbol.type,.predicate(1),"\(nok) fofn :: \(fofn)")
    XCTAssertEqual("~(p(f(X)))", fofn.description,nok)

    let fofe : Node = "@fof p=X"
    XCTAssertEqual(fofe.symbol.type,.equation,"\(nok) fofe :: \(fofe)")
    XCTAssertEqual("p=X", fofe.description,nok)

    let clause : Node = "@cnf ~p(f(X))"
    XCTAssertEqual(clause.symbol.type,.disjunction,"\(nok) clause :: \(clause)")
    XCTAssertEqual("(~(p(f(X))))", clause.description,nok)
  }

  func testHeuristics() {
    let a : Node = "a"
    XCTAssertEqual(a.symbol.type,.function(0),"\(nok) a :: \(a)")
    XCTAssertEqual("a", a.description,nok)

    let X : Node = "X"
    XCTAssertEqual(X.symbol.type,.variable,"\(nok) X :: \(X)")
    XCTAssertEqual("X", X.description,nok)

    let fX : Node = "f(X)"
    XCTAssertEqual(fX.symbol.type,.function(1),"\(nok) fX :: \(fX)")
    XCTAssertEqual("f(X)", fX.description,nok)

    let equal : Node = "a=X"
    XCTAssertEqual(equal.symbol.type,.equation,"\(nok) equal :: \(equal)")
    XCTAssertEqual("a=X", equal.description,nok)

    let neq : Node = "a!=X"
    XCTAssertEqual(neq.symbol.type,.inequation,"\(nok) neq :: \(neq)")
    XCTAssertEqual("a!=X", neq.description,nok)

    let not : Node = "~p(f(X))"
    XCTAssertEqual(not.symbol.type,.negation,"\(nok) not :: \(not)")
    XCTAssertEqual("~(p(f(X)))", not.description,nok)

    let dis : Node = "p|q"
    XCTAssertEqual(dis.symbol.type,.disjunction,"\(nok) dis :: \(dis)")
    XCTAssertEqual("(p|q)", dis.description,nok)

    let con : Node = "p&q"
    XCTAssertEqual(con.symbol.type,.conjunction,"\(nok) con :: \(con)")
    XCTAssertEqual("(p&q)", con.description,nok)

    let impl : Node = "p=>q"
    // XCTAssertEqual(impl.symbol.type,.implication,"\(nok) impl :: \(impl)")
    XCTAssertEqual("(p=>q)", impl.description,nok)

  }

  func testUndefined() {
    let ab : Node = "@cnf a&b" // =>
    // XCTAssertEqual(ab.symbol.type,.function(2),"\(nok) ab :: \(ab)")
    XCTAssertEqual("@cnf a&b ❌ .parse error",ab.description)

  }


}
