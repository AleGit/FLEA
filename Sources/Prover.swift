import Foundation
import CYices

// MARK: protocols

protocol Prover {
    /// Initialize Prover with problem name, e.g. 'PUZ001-1':
    /// Returns nil if problem file cannot be found or parsed.
    init?(problem name: String)

    /// returns nil if timeout was reached before an a proof was found
    /// returns true if problem is a theorem, e.g. negated conjecture is unsatisfiable (with proof)
    /// returns false if problem is not a theorem, e.g. set of clause is saturated and satisfiable
    func run(timeout: TimeInterval) -> Bool?
}

protocol YicesProver: Prover {
    func yicesLiterals(clauseIndex: Int) -> Set<term_t>

    /// returns nil, if none of the literals holds
    func selectedYicesLiteral(clauseIndex: Int) -> term_t?

    /// returns nil if yicesLiteral not in yicesLiterals(clauseIndex: clauseIndex)
    func selectedLiteralIndex(clauseIndex: Int, yicesLiteral: term_t) -> Int?
}

// MARK: - protocol extensions

extension Prover {
    static func URLAndFile(problem name: String) -> (URL, Tptp.File)? {
        guard let url = URL(fileURLWithProblem: name) else {
            Syslog.error { "Problem \(name) could not be found." }
            return nil
        }
        guard let file = Tptp.File(url:url) else {
            Syslog.error { "Problem \(name) at \(url.path) could not be read and parsed." }
            return nil
        }
        return (url, file)
    }

    static func URLAndFile(axiom name: String, problemURL: URL?) -> (URL, Tptp.File)? {
        guard let url = URL(fileURLWithAxiom: name, problemURL: problemURL) else {
            Syslog.error { "Axiom \(name) could not be found. (Problem: \(problemURL?.path))" }
            return nil
        }

        guard let file = Tptp.File(url:url) else {
            Syslog.error {
                "Axiom \(name) at \(url.path) could not be read or parsed."
                }
            return nil
        }
        return (url, file)
    }
}
