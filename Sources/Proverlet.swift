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

        for (name, list, url)  in file.includeSelectionURLTriples(url: url) {
            guard let axioms: Array<(String, Tptp.Role, N)> = Tptp.File(url: url)?.nameRoleClauseTriples(
                predicate: { n, _ in list.isEmpty || Set(list).contains(n) }
            ) else {
                Syslog.error { "\(name) at \(url) was not read correctly." }
                return nil
            }
            parsedClauses += axioms
            parsedFiles.append((url.path, axioms.count))
        }
    }
}

extension Proverlet {


    func run(timeout: TimeInterval) -> Bool? {
        Syslog.fail { "MISSING IMPLEMENTATION" }
        return nil
    }

    var fileCount: Int {
        return parsedFiles.count
    }

    var clauseCount: Int {
        return parsedClauses.count
    }
}
