//  Copyright © 2016 Alexander Maringele. All rights reserved.

import CYices

/// `Proverlet` implements a procedure to process a list of clauses to infer new clauses
/// until an unsatisfiable set of ground instances was found or no new clauses could be inferred.
/// The procedure may not terminate or may consume to much space and time.
final class Proverlet<N:Node>: Prover
where N:SymbolStringTyped {
    /// List of (file path, number of clauses) pairs.
    fileprivate var parsedFiles = Array<(String, Int)>()

    /// List of (clause name, clause role, clause) triples.
    fileprivate var parsedClauses: Array<(String, Tptp.Role, N)>

    /// a at least syntactically variant free collection of clauses
    /// - syntactically variant free: {p(X)|q(Y), q(Z)|p(X)} excludes p(Y)|q(Z)
    /// - semantically variant free: {p(X)|q(Y)} excludes q(Z)|p(X)
    fileprivate let clauses = Clauses<N>()

    init(axioms: [N]) {
        Syslog.info { "initializing with in memory clauses" }
        parsedClauses = Array<(String, Tptp.Role, N)>() // stays empty

        for clause in axioms {
            let _ = clauses.insert(clause:clause)
        }
    }



    /// initialize with the name of a problem
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

        // preliminary

        for (_, _, clause) in parsedClauses {
            let _ = clauses.insert(clause:clause)
        }

        // preliminary
        Syslog.warning(condition: clauses.count != parsedClauses.count) {
            "Problem '\(name)' holds mutliple veriants of clauses."
        }
    }

    var fileCount: Int {
        return parsedFiles.count
    }

    var clauseCount: Int {
        return clauses.count
    }
}

extension Proverlet {

    /*
        adoption of the given clause algorithm (reference?)
        ==================================
        - initialize a list of passive clauses with the clauses of a problem
        - create an empty list of usable clauses
        - the following may loop forever (e.g. satisfiable set of clauses with an infinite model)
          or exceed all reasonable costs (time and space):
            1. select a clause c_i from passive clauses (by a strategy)
            2. assert grounded c_i in SMT solver context
            3. goto 12 if not SAT(context)
            4. get a model from satisfiable context
            5. check selected literals of usable clauses and
               unselect selected literals that not hold in actual model
            6. add clause c_i to usable clauses, remove c_i from passive clauses
            7. select a clause c_j without a selected literal from usable clauses, e.g c_i
            8. select literal l_j_k from c_j and search for clashing selected literals
            9. derive clauses by clashes and equality axioms and add
               new clauses (i.e. no variants exsit) to the passive clauses.
            10. goto 7 if at least one usable clause without a selected literal is left.
            11. goto 1 if at least one passive clause is left.
            12. SAT(problem) <=> SAT(context)
        - maintain index structures for the search for variants and clashing literals:
            ad 5. remove deselected literals from selecected literal index.
            ad 9. insert literal l_j_k -> c_j to selected literal index,

        */
    func run(timeout: TimeInterval) -> Bool? {
        Syslog.fail { "MISSING IMPLEMENTATION" }

        return nil
    }

    func runSequentially(timeout: TimeInterval = 30.0) -> Bool {
        let stopTime = AbsoluteTimeGetCurrent() + timeout

        let context = Yices.Context()
        var i = 0
        while i < clauses.count && AbsoluteTimeGetCurrent() < stopTime {

            guard clauses.insure(clauseReference: i, context: context) else {
                return false
            }
            // print(i, "of", clauses.count, "\t", clauses.clause(byReference: i))


            clauses.processPending()





            i += 1
        }

        return context.isSatisfiable

    }
}

