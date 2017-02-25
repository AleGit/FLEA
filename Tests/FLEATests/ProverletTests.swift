import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class ProverletTests: YicesTestCase {

    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (ProverletTests) -> () throws -> Void)] {
        return [
            // ("testInitPUZ001c1", testInitPUZ001c1),
            // ("testInitPUZ062c1", testInitPUZ062c1),
            ("testPUZs", testPUZs),
        ]
    }

    // local private adoption of node protocols to avoid any side affects
    private final class TestNode: SymbolNameTyped, SymbolTabulating, Sharing, Node,
        ExpressibleByStringLiteral {
        typealias S = Int
        typealias N = TestNode

        static var symbols = StringIntegerTable<S>()
        static var pool = WeakSet<N>()
        // var folks = WeakSet<N>() // protocol Kin

        var symbol: S = -1 // N.symbolize(name: Tptp.wildcard, type: .variable)
        var nodes: [N]?

        var description: String { return defaultDescription }
        lazy var hashValue: Int = self.defaultHashValue
    }

    func testPUZs() {
        for (problem, noc, nof, _) in [
            ("PUZ001-1", 12, 1, false),
            ("PUZ007-1", 28, 2, true),
        ] {
            guard let theProver = FLEA.Proverlet<TestNode>(problem: problem) else {
                XCTFail(nok)
                return
            }

            XCTAssertEqual(noc, theProver.clauseCount, nok)
            XCTAssertEqual(nof, theProver.fileCount, nok)
        }
    }

    func testInfDom() {
        let axioms: [TestNode] = [
            "@cnf s(X) != zero",
            "s(X)!=s(Y) | X = Y",
        ]

        let prover = Proverlet(axioms: axioms)

        for run in 1 ... 10 {
            let satisfiable = prover.runSequentially(timeout: 1)
            print(run, prover.clauseCount, prover.ignoreCount, satisfiable)
        }
    }

    func testPeano() {
        // https://en.wikipedia.org/wiki/Peano_axioms
        let axioms: [TestNode] = [
            // "@cnf natural(zero) ",               // 0 is a natural number.
            /*
             "@cnf X=X ",                         // reflexivity
             " X != Y | Y = X ",                   // symmetry
             " X != Y | Y != Z | X = Y ",          // transitifity
             " X != Y | ~natural(X) | natural(Y) ", // congruence (closed under equality)
             */

            // " ~natural(X)|natural(s(X)) ",      // For every natural number n, S(n) is a natural number.

            // " X != Y | s(X)=s(Y) ",
            // For all natural numbers m and n, m = n if and only if S(m) = S(n). That is, S is an injection.
            " s(X)!=s(Y) | X = Y ",
            
            "@cnf s(X) != zero",

            // " ~natural(X) | s(X)!=zero "
            // For every natural number n, S(n) = 0 is false. That is, there is no natural number whose successor is 0.
        ]

        let prover = Proverlet(axioms: axioms)

        let satisfiable = prover.runSequentially()
        print(prover.clauseCount, satisfiable)
    }

    func testSimple() {
        let axioms: [TestNode] = [
            "@cnf s(X) != zero",
            "s(X)!=s(Y) | X = Y",
            "@cnf s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(zero))))))))))))))))))))=s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(zero))))))))))))))))))))))",
        ]

        let prover = Proverlet(axioms: axioms)

        let satisfiable = prover.runSequentially(timeout: 0.4)
        print(prover.clauseCount, satisfiable)
    }
}
