final class Proverlet<N:Node>: Prover
where N:SymbolStringTyped {
    /// List of (file path, number of clauses) pairs.
    fileprivate var parsedFiles = Array<(String, Int)>()

    /// List of (clause name, clause role, clause) triples.
    fileprivate var parsedClauses: Array<(String, Tptp.Role, N)>

    init?(problem name: String) {
        Syslog.info { "problem name = \(name)" }

        // read and parse the main (problem) file

        guard let (url, file) = Proverlet.URLAndFile(problem: name) else { return nil }

        parsedClauses = file.nameRoleClauseTriples()
        parsedFiles.append((url.path, parsedClauses.count))

        // read and parse the included (axiom) files

        for (name, list, url) in file.includeSelectionURLTriples(url: url) {
            guard let file = Tptp.File(url: url) else {
                Syslog.error { "\(name) at \(url) was not read correctly." }
                return nil
            }

            let axioms: Array<(String, Tptp.Role, N)> = file.nameRoleClauseTriples(
                predicate: { n, _ in list.isEmpty || Set(list).contains(n) }
            )

            Syslog.error(condition: file.containsIncludes) {
                "(NIY) Included file \(name) at \(url) contains include lines."
            }

            parsedClauses += axioms
            parsedFiles.append((url.path, axioms.count))
        }
    }

    var fileCount: Int {
        return parsedFiles.count
    }

    var clauseCount: Int {
        return parsedClauses.count
    }
}

extension Proverlet {


    func run(timeout: TimeInterval) -> Bool? {
        Syslog.fail { "MISSING IMPLEMENTATION" }
        return nil
    }
}
