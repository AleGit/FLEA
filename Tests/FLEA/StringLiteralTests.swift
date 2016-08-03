import XCTest

@testable import FLEA


private typealias Node = FLEA.Tptp.SimpleNode



/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class StringLiteralTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (StringLiteralTests) -> () throws -> Void)]  {
    return [
      ("testStringLiterals", testStringLiterals)
    ]
  }

  /// accumulate four distict nodes
  func testStringLiterals() {
    let a : Node = "a"
    XCTAssertEqual(a.symbol.type,.function,"\(nok) a :: \(a)")

    let X : Node = "X"
    XCTAssertEqual(X.symbol.type,.variable,"\(nok) X :: \(X)")

    let fX : Node = "f(X)"
    XCTAssertEqual(fX.symbol.type,.function,"\(nok) fX :: \(fX)")

    let termfX : Node = "@term f(X)"
    XCTAssertEqual(termfX.symbol.type,.function,"\(nok) termfX :: \(termfX)")

    let pfX : Node = "@predicate p(f(X))"
    XCTAssertEqual(pfX.symbol.type,.predicate,"\(nok) pfX :: \(pfX)")
    //
    let cnf : Node = "@cnf p(f(X))" // =>
    XCTAssertEqual(cnf.symbol.type,.disjunction,"\(nok) cnf :: \(cnf)")

    let equal : Node = "a=X"
    XCTAssertEqual(equal.symbol.type,.equation,"\(nok) equal :: \(equal)")

    let neq : Node = "a!=X"
    XCTAssertEqual(neq.symbol.type,.inequation,"\(nok) neq :: \(neq)")

    let not : Node = "~p(f(X))"
    XCTAssertEqual(not.symbol.type,.negation,"\(nok) not :: \(not)")

    let clause : Node = "@cnf ~p(f(X))"
    XCTAssertEqual(clause.symbol.type,.disjunction,"\(nok) clause :: \(clause)")

    let dis : Node = "p|q"
    XCTAssertEqual(dis.symbol.type,.disjunction,"\(nok) dis :: \(dis)")

    let con : Node = "p&q"
    XCTAssertEqual(con.symbol.type,.conjunction,"\(nok) con :: \(con)")

    let impl : Node = "p=>q"
    XCTAssertEqual(impl.symbol.type,.implication,"\(nok) impl :: \(impl)")

    let fofp : Node = "@fof p(f(X))"
    XCTAssertEqual(fofp.symbol.type,.predicate,"\(nok) fofp :: \(fofp)")

    let fofn : Node = "@fof ~p(f(X))"
    XCTAssertEqual(fofn.symbol.type,.negation,"\(nok) fofn :: \(fofn)")

    let fofe : Node = "@fof p=X"
    XCTAssertEqual(fofe.symbol.type,.equation,"\(nok) fofe :: \(fofe)")
  }


}
