



final class Proverlet<N:Node>: Prover
where N:SymbolStringTyped {
    /// List of (file path, number of clauses) pairs.
    fileprivate var parsedFiles = Array<(String, Int)>()

    /// List of (clause name, clause role, clause) triples.
    fileprivate var parsedClauses: Array<(String, Tptp.Role, N)>


    /// index structure to find clashing selected literals
    fileprivate var literals = TrieClass<SymHop<N.Symbol>, Int>()

    /// index structure to find clause variants
    fileprivate var variants = TrieClass<N.Symbol, Int>()



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
                "Included axiom file \(name) at \(url) contains include lines."
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

    /*
        adoption of the given clause algorithm (reference?)
        ==================================
        - initialize a list of passive clauses with the clauses of a problem
        - create an empty list of usable clauses
        - this may loop forever (e.g. satisfiable with infinite model)
          or exceed all reasonable costs (time and space)
            1. select a clause c_i from passive clauses (by a strategy)
            2. assert grounded c_i in SMT solver context
            3. goto 12 if not SAT(context)
            4. get a model from satisfiable context
            5. check selected literals of usable clauses and
               unselect selected literals that not hold in actual model
            6. add clause c_i to usable clauses, remove c_i from passive clauses
            7. select a clause c_j without a selected literal from usable clauses, e.g c_i
            8. select literal from c_j and search for clashing selected literals
            9. derive clauses by clashes and equality axioms and add
               new clauses (i.e. no variants exsit) to the passive clauses.
            10. goto 7 if at least one usable clause without a selected literal is left.
            11. goto 1 if at least one passive clause is left.
            12. SAT(problem) <=> SAT(context)
        - maintain index structures for the search for variants and clashing literals.
        */
    func run(timeout: TimeInterval) -> Bool? {
        Syslog.fail { "MISSING IMPLEMENTATION" }
        return nil
    }
}
