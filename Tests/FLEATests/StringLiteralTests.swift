import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class StringLiteralTests: FleaTestCase {
    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (StringLiteralTests) -> () throws -> Void)] {
        return [
            ("testAnnotations", testAnnotations),
            ("testHeuristics", testHeuristics),
            ("testUndefined", testUndefined),
        ]
    }

    // local private adoption of protocol to avoid any side affects
    private final class LocalSimpleNode: SymbolNameTyped, Node, ExpressibleByStringLiteral {
        typealias S = Tptp.Symbol

        var symbol: S = LocalSimpleNode.symbolize(string: "*", type: .variable)
        var nodes: [LocalSimpleNode]?

        lazy var hashValue: Int = self.defaultHashValue
        lazy var description: String = self.defaultDescription
    }

    func testAnnotations() {
        let pfX: LocalSimpleNode = "p(f(X))"
        XCTAssertEqual(pfX.symbol.type, .function(1))
        XCTAssertEqual("p(f(X))", pfX.description, nok)

        let fof: LocalSimpleNode = "@fof p(f(X))"
        XCTAssertEqual(fof.symbol.type, .predicate(1), "\(nok) fof :: \(fof)")
        XCTAssertEqual("p(f(X))", fof.description, nok)

        let cnf: LocalSimpleNode = "@cnf p(f(X))" // =>
        XCTAssertEqual(cnf.symbol.type, .disjunction, "\(nok) cnf :: \(cnf)")
        XCTAssertEqual(cnf.nodes!.first!.symbol.type, .predicate(1), "\(nok) cnf :: \(cnf)")
        XCTAssertEqual("(p(f(X)))", cnf.description, nok)

        let fofp: LocalSimpleNode = "@fof p(f(X))"
        XCTAssertEqual(fofp.symbol.type, .predicate(1), "\(nok) fofp :: \(fofp)")
        XCTAssertEqual("p(f(X))", fofp.description, nok)

        let fofn: LocalSimpleNode = "@fof ~p(f(X))"
        XCTAssertEqual(fofn.symbol.type, .negation, "\(nok) fofn :: \(fofn)")
        XCTAssertEqual(fofn.nodes!.first!.symbol.type, .predicate(1), "\(nok) fofn :: \(fofn)")
        XCTAssertEqual("~(p(f(X)))", fofn.description, nok)

        let npfX: LocalSimpleNode = "@fof ~p(f(X))"
        XCTAssertEqual(npfX.symbol.type, .negation, "\(nok) fofn :: \(fofn)")
        XCTAssertEqual(npfX.nodes!.first!.symbol.type, .predicate(1), "\(nok) fofn :: \(fofn)")
        XCTAssertEqual("~(p(f(X)))", npfX.description, nok)

        let fofe: LocalSimpleNode = "@fof p=X"
        XCTAssertEqual(fofe.symbol.type, .equation, "\(nok) fofe :: \(fofe)")
        XCTAssertEqual("p=X", fofe.description, nok)

        let cnfe: LocalSimpleNode = "@cnf p=X"
        XCTAssertEqual(cnfe.symbol.type, .disjunction, "\(nok) cnfe :: \(cnfe)")
        XCTAssertEqual(cnfe.nodes!.first!.symbol.type, .equation, "\(nok) cnfe :: \(cnfe)")
        XCTAssertEqual("(p=X)", cnfe.description, nok)

        let cnfne: LocalSimpleNode = "@cnf p!=X"
        XCTAssertEqual(cnfne.symbol.type, .disjunction, "\(nok) cnfne :: \(cnfne)")
        XCTAssertEqual(cnfne.nodes!.first!.symbol.type, .inequation, "\(nok) cnfne :: \(cnfne)")
        XCTAssertEqual("(p!=X)", cnfne.description, nok)

        let peX: LocalSimpleNode = "p=X"
        XCTAssertEqual(peX.symbol.type, .equation, "\(nok) peX :: \(peX)")
        XCTAssertEqual("p=X", fofe.description, nok)

        let clause: LocalSimpleNode = "@cnf ~p(f(X))"
        XCTAssertEqual(clause.symbol.type, .disjunction, "\(nok) clause :: \(clause)")
        XCTAssertEqual("(~(p(f(X))))", clause.description, nok)
    }

    func testHeuristics() {
        let a: LocalSimpleNode = "a"
        XCTAssertEqual(a.symbol.type, .function(0), "\(nok) a :: \(a)")
        XCTAssertEqual("a", a.description, nok)

        let X: LocalSimpleNode = "X"
        XCTAssertEqual(X.symbol.type, .variable, "\(nok) X :: \(X)")
        XCTAssertEqual("X", X.description, nok)

        let fX: LocalSimpleNode = "f(X)"
        XCTAssertEqual(fX.symbol.type, .function(1), "\(nok) fX :: \(fX)")
        XCTAssertEqual("f(X)", fX.description, nok)

        let equal: LocalSimpleNode = "a=X"
        XCTAssertEqual(equal.symbol.type, .equation, "\(nok) equal :: \(equal)")
        XCTAssertEqual("a=X", equal.description, nok)

        let neq: LocalSimpleNode = "a!=X"
        XCTAssertEqual(neq.symbol.type, .inequation, "\(nok) neq :: \(neq)")
        XCTAssertEqual("a!=X", neq.description, nok)

        let not: LocalSimpleNode = "~p(f(X))"
        XCTAssertEqual(not.symbol.type, .negation, "\(nok) not :: \(not)")
        XCTAssertEqual("~(p(f(X)))", not.description, nok)

        let dis: LocalSimpleNode = "p|q"
        XCTAssertEqual(dis.symbol.type, .disjunction, "\(nok) dis :: \(dis)")
        XCTAssertEqual("(p|q)", dis.description, nok)

        let con: LocalSimpleNode = "p&q"
        XCTAssertEqual(con.symbol.type, .conjunction, "\(nok) con :: \(con)")
        XCTAssertEqual("(p&q)", con.description, nok)

        let impl: LocalSimpleNode = "p=>q"
        // XCTAssertEqual(impl.symbol.type,.implication,"\(nok) impl :: \(impl)")
        XCTAssertEqual("(p=>q)", impl.description, nok)
    }

    func testUndefined() {
        let ab: LocalSimpleNode = "@cnf a&b" // =>
        // XCTAssertEqual(ab.symbol.type,.function(2),"\(nok) ab :: \(ab)")
        XCTAssertEqual("@cnf a&b ❌ .parse error", ab.description)
    }
}
