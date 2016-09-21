import Foundation

protocol Prover {
    /// Initialize Prover with problem name, e.g. 'PUZ001-1':
    /// Returns nil if problem file cannot be found or parsed.
    init?(problem name: String)

    /// - true if set of clauses are saturated and satisfiable.
    /// - false if set of clauses is unsatisfiable.
    /// - nil in timeout was reached.
    func run(timeout: AbsoluteTime) -> Bool?

}

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
                "Axiom \(name) at \(url.path) could not be read and parsed."
                }
            return nil
        }
        return (url, file)
    }
}
