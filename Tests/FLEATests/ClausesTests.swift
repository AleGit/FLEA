import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class ClausesTests: YicesTestCase {

    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (ClausesTests) -> () throws -> Void)] {
        return [
            ("testClauses", testClauses),
            ("testLiterals", testLiterals),
        ]
    }

    // local private adoption of node protocols to avoid any side affects
    private final class TestNode: SymbolNameTyped, SymbolTabulating, Sharing, Node,
        ExpressibleByStringLiteral {
        typealias S = Int
        typealias N = TestNode

        static var symbols = IntegerSymbolTable<S>()
        static var pool = WeakSet<N>()
        // var folks = WeakSet<N>() // protocol Kin

        var symbol: S = -1 // N.symbolize(name: Tptp.wildcard, type: .variable)
        var nodes: [N]?

        // var description: String { return defaultDescription }
        lazy var hashValue: Int = self.defaultHashValue
    }

    func testClauses() {

        let clauses = Clauses<TestNode>()

        XCTAssertTrue((true, 0) == clauses.insert(clause: "p(X)|q(Y)")) // new
        XCTAssertTrue((false, 0) == clauses.insert(clause: "p(X)|q(Y)"))
        XCTAssertTrue((true, 1) == clauses.insert(clause: "p(X)|q(X)")) // new

        XCTAssertTrue((true, 2) == clauses.insert(clause: "@cnf p(X)")) // new

        XCTAssertTrue((false, 2) == clauses.insert(clause: "@cnf p(Z)"))
        XCTAssertTrue((false, 0) == clauses.insert(clause: "p(Z)|q(Y)"))
        XCTAssertTrue((false, 1) == clauses.insert(clause: "p(Z)|q(Z)"))

        XCTAssertTrue((true, 3) == clauses.insert(clause: "q(X)|p(Y)")) // unfortunately new

        XCTAssertEqual(4, clauses.count)
    }

    func testLiterals() {
        let (clause1, literals1, shuffled1) = Yices.clause("p(X)|p(Z)|q(Y)" as TestNode)
        let (clause2, literals2, shuffled2) = Yices.clause("q(X)|p(Y)" as TestNode)
        let (clause3, literals3, shuffled3) = Yices.clause("p(X)|q(Y)" as TestNode)

        let (clause4, literals4, shuffled4) = Yices.clause("~p(X)|p(Z)|q(Y)" as TestNode)
        let (clause5, literals5, shuffled5) = Yices.clause("q(X)|~p(Y)" as TestNode)
        let (clause6, literals6, shuffled6) = Yices.clause("~p(X)|q(Y)" as TestNode)

        XCTAssertEqual(clause1, clause2, nok)
        XCTAssertEqual(clause1, clause3, nok)
        XCTAssertEqual(2, clause4, nok)
        XCTAssertEqual(clause5, clause6)
    }

    func testClashings() {
        let context = Yices.Context()

        let clauses = Clauses<TestNode>()

        XCTAssertTrue((true, 0) == clauses.insert(clause: "p(X) | a!=a"))
        XCTAssertTrue((true, 1) == clauses.insert(clause: "X!=Y | p(a)"))
        XCTAssertTrue((true, 2) == clauses.insert(clause: "~p(b) | c!=c"))

        XCTAssertTrue(clauses.insure(clauseReference: 0, context: context))
        clauses.activate(literalReference: Pair(0, 0))

        XCTAssertTrue(clauses.insure(clauseReference: 1, context: context))
        clauses.activate(literalReference: Pair(1, 1))

        XCTAssertNil(clauses.clashingLiterals(literalReference: Pair(1, 1)))
        clauses.activate(literalReference: Pair(2, 0))

        XCTAssertTrue(clauses.insure(clauseReference: 2, context: context))

        let clashings = clauses.clashingLiterals(literalReference: Pair(2, 0))!
        print(clashings)

        let derivations = clauses.derivations(literalReference: Pair(2, 0))
        for derivation in derivations {
            print(derivation.description, derivation)
        }
    }

    func testPeano() {
        // https://en.wikipedia.org/wiki/Peano_axioms
        let axioms: [TestNode] = [
            "@cnf natural(zero)", // 0 is a natural number.

            "@cnf X=X", // reflexivity
            "X != Y | Y = X", // symmetry
            "X != Y | Y != Z | X = Y", // transitifity
            "X != Y | ~natural(X) | natural(Y)", // congruence (closed under equality)

            "~natural(X)|natural(s(X))", // For every natural number n, S(n) is a natural number.

            "X != Y | s(X)=s(Y)",
            // For all natural numbers m and n, m = n if and only if S(m) = S(n). That is, S is an injection.
            "s(X)!=s(Y) | X = Y",

            "~natural(X)|s(X)!=zero",
            // For every natural number n, S(n) = 0 is false. That is, there is no natural number whose successor is 0.
        ]

        let context = Yices.Context()
        let clauses = Clauses<TestNode>()

        for axiom in axioms {
            let (a, b) = clauses.insert(clause: axiom)
            let c = clauses.insure(clauseReference: b, context: context)
            print("\(a),\(b),\(c)) >> \(axiom)")
        }

        print(context.isSatisfiable ? "\(ok) Context is satisfiable." : "\(nok) Context is not satisfiable.")
    }
}
