import Foundation
import CYices

final class ProverY<N:Node>: Prover
where N:SymbolStringTyped {
    /// keep a history of read files
    var files = Array<(String, URL, Int, Int)>()

    /// all clauses from all read files
    var clauses: Array<(String, Tptp.Role, N)>

    fileprivate var insuredClauses: Dictionary<Int, Yices.Tuple>
    fileprivate var deadline: AbsoluteTime = 0.0
    fileprivate var context = Yices.Context()

    /// Initialize a prover with a problem, read the problem file and axiom files.
    init?(problem name: String) {
        Syslog.info { "problem name = \(name)" }

        guard let (url, file) = ProverY.URLAndFile(problem: name) else { return nil }

        clauses = file.nameRoleClauseTriples()
        let includes = file.includeSelectionURLTriples(url: url)

        files.append((name, url, clauses.count, includes.count))

        for (name, list, url) in includes {
            guard let axioms: Array<(String, Tptp.Role, N)>
            = Tptp.File(url: url)?.nameRoleClauseTriples(
                predicate: { n, _ in list.isEmpty || Set(list).contains(n) }
            ) else {
                Syslog.error { "\(name) at \(url) was not read correctly." }
                return nil
            }
            clauses += axioms
            files.append((name, url, axioms.count, 0))
        }

        insuredClauses = Dictionary<Int, Yices.Tuple>(minimumCapacity: clauses.count)
    }

    // simplest selection funciton
    func selectClauseIndex () -> Int? {
        guard insuredClauses.count <= clauses.count else { return nil }
        return insuredClauses.count
    }
}

extension ProverY {
    func run(timeout: TimeInterval) -> Bool? {
        deadline = AbsoluteTimeGetCurrent() + timeout

        guard let name = files.first?.0 else {
            Syslog.error { "Problem is empty" }
            return true // an empty problem is a theorem
        }
        Syslog.info { "\(timeout) s. '\(name)'" }

        while processNextClause() {
            let time = AbsoluteTimeGetCurrent()
            guard time < deadline else {
                Syslog.info { "\(timeout) s, expired by \(time - deadline) s. '\(name)'" }
                return nil
            }
        }

        Syslog.info { "\(deadline - AbsoluteTimeGetCurrent()) s remaining. '\(name)'" }

        // the loop has saturated
        return !context.isSatisfiable
    }


    /// Process clause, i.e. encode and assert clause with Yices
    /// - returns false if
    ///     - no unprocessed clause is available
    ///     - context is not satifaible anymore
    /// - returns true otherwise
    private func processNextClause() -> Bool {
        guard let clauseIndex = selectClauseIndex(), clauseIndex < clauses.count else {
            Syslog.error(condition: { insuredClauses.count != clauses.count }) {
                "Just \(insuredClauses.count) of \(clauses.count) clauses were processed." }

            Syslog.notice(condition: { insuredClauses.count == clauses.count }) {
                "All \(clauses.count) clauses were processed." }

            return false
        }

        assert(insuredClauses[clauseIndex] == nil)
        insuredClauses[clauseIndex] = context.insure(clause: clauses[clauseIndex].2)

        guard context.isSatisfiable else {
            return false
        }

        // TODO: derive new clauses


        return true
    }


}

extension ProverY {
}
