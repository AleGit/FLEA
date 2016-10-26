import Foundation
import CYices

// MARK: protocols

protocol Prover {
    /// Initialize Prover with problem name, e.g. 'PUZ001-1':
    /// Returns nil if problem file cannot be found or parsed.
    init?(problem name: String)

    /// returns nil if timeout was reached before a proof was found
    /// returns true if problem is a theorem, e.g. negated conjecture is unsatisfiable (with proof)
    /// returns false if problem is not a theorem, e.g. set of clause is saturated and satisfiable
    func run(timeout: TimeInterval) -> Bool?

    /// report the number of files read from storage
    var fileCount: Int { get }

    /// report the number of clauses in prover repository
    var clauseCount: Int { get }
}

// MARK: - protocol extensions

extension Prover {
    /// Searches for a problem by name, convention, and TPTP Path,
    /// e.g. "PUZ001-1" => ~/TPTP/Problems/PUZ001-1p
    /// It will return
    /// - a pair with the problem file url and content if successful
    /// - nil if problem file could not be located, read or parsed.
    static func URLAndFile(problem name: String) -> (URL, Tptp.File)? {
        /// find an accessible problem file(with $name extension '.p')
        guard let url = URL(fileURLWithProblem: name) else {
            Syslog.error {  "Problem \(name) could not be found." }
            return nil
        }
        /// parse accessible problem file
        guard let file = Tptp.File(url:url) else {
            Syslog.error { "Problem \(name) at \(url.path) could not be read or parsed." }
            return nil
        }
        return (url, file)
    }

    /// Search and parse an axiom file by name, problem url, conventions, and TPTP Path,
    /// e.g. the search starts relatively to the problem file.
    /// It will return
    /// - a pair with the axiom file url and content if successful
    /// - nil if axiom file could not be located, read or parsed.
    static func URLAndFile(axiom name: String, problemURL: URL?) -> (URL, Tptp.File)? {
        /// find an accessible axiom file (with $name and extension '.ax')
        guard let url = URL(fileURLWithAxiom: name, problemURL: problemURL) else {
            Syslog.error { "Axiom \(name) could not be found. (Problem: \(problemURL?.path))" }
            return nil
        }

        /// parse accessible axiom file
        guard let file = Tptp.File(url:url) else {
            Syslog.error { "Axiom \(name) at \(url.path) could not be read or parsed." }
            return nil
        }
        return (url, file)
    }
}
