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
    XCTAssertEqual(pfX.symbol.type,.function,"\(nok) pfX :: \(pfX)")
    XCTAssertEqual("p(f(X))", pfX.description,nok)

    let fof : Node = "@fof p(f(X))"
    XCTAssertEqual(fof.symbol.type,.predicate,"\(nok) fof :: \(fof)")
    XCTAssertEqual("p(f(X))", fof.description,nok)

    let cnf : Node = "@cnf p(f(X))" // =>
    XCTAssertEqual(cnf.symbol.type,.disjunction,"\(nok) cnf :: \(cnf)")
    XCTAssertEqual(cnf.nodes!.first!.symbol.type,.predicate,"\(nok) cnf :: \(cnf)")
    XCTAssertEqual("(p(f(X)))", cnf.description,nok)

    let fofp : Node = "@fof p(f(X))"
    XCTAssertEqual(fofp.symbol.type,.predicate,"\(nok) fofp :: \(fofp)")

    let fofn : Node = "@fof ~p(f(X))"
    XCTAssertEqual(fofn.symbol.type,.negation,"\(nok) fofn :: \(fofn)")
    XCTAssertEqual(fofn.nodes!.first!.symbol.type,.predicate,"\(nok) fofn :: \(fofn)")

    let fofe : Node = "@fof p=X"
    XCTAssertEqual(fofe.symbol.type,.equation,"\(nok) fofe :: \(fofe)")

    let clause : Node = "@cnf ~p(f(X))"
    XCTAssertEqual(clause.symbol.type,.disjunction,"\(nok) clause :: \(clause)")
  }

  func testHeuristics() {
    let a : Node = "a"
    XCTAssertEqual(a.symbol.type,.function,"\(nok) a :: \(a)")

    let X : Node = "X"
    XCTAssertEqual(X.symbol.type,.variable,"\(nok) X :: \(X)")

    let fX : Node = "f(X)"
    XCTAssertEqual(fX.symbol.type,.function,"\(nok) fX :: \(fX)")

    let equal : Node = "a=X"
    XCTAssertEqual(equal.symbol.type,.equation,"\(nok) equal :: \(equal)")

    let neq : Node = "a!=X"
    XCTAssertEqual(neq.symbol.type,.inequation,"\(nok) neq :: \(neq)")

    let not : Node = "~p(f(X))"
    XCTAssertEqual(not.symbol.type,.negation,"\(nok) not :: \(not)")

    let dis : Node = "p|q"
    XCTAssertEqual(dis.symbol.type,.disjunction,"\(nok) dis :: \(dis)")

    let con : Node = "p&q"
    XCTAssertEqual(con.symbol.type,.conjunction,"\(nok) con :: \(con)")

    let impl : Node = "p=>q"
    XCTAssertEqual(impl.symbol.type,.implication,"\(nok) impl :: \(impl)")

  }

  func testUndefined() {
    let ab : Node = "@cnf a&b" // =>
    XCTAssertEqual(ab.symbol.type,.function,"\(nok) ab :: \(ab)")
    XCTAssertEqual("@cnf a&b ❌ .parse error",ab.description)

  }


}
