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
