import Foundation
import CYices

final class ProverY<N:Node>: Prover
where N:SymbolStringTyped {
    /// keep a history of read files
    var files = Array<(String, URL, Int, Int)>()

    /// all clauses from all read files
    var clauses: Array<(String, Tptp.Role, N)>

    var insuredClauses: Set<Int>

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

        insuredClauses = Set<Int>(minimumCapacity: clauses.count)
    }

    // simplest selection funciton
    func selectClauseIndex () -> Int? {
        guard insuredClauses.count <= clauses.count else { return nil }
        return insuredClauses.count
    }
}

extension ProverY {
    func run(timeout: TimeInterval) -> Bool? {
        let deadline = AbsoluteTimeGetCurrent() + timeout

        guard let name = files.first?.0 else {
            Syslog.error { "Problem is empty" }
            // an empty problem is a theorem
            return true
        }
        Syslog.info { "\(name) timeout = \(timeout) s" }

        while let clauseIndex = selectClauseIndex() {
            let time = AbsoluteTimeGetCurrent()
            guard deadline < time else {
                Syslog.info { "\(name) timeout of \(timeout) s worn down by \(time-deadline) s" }
                return nil
            }
        }

        guard deadline <= AbsoluteTimeGetCurrent() else {
            Syslog.warning { "last round took too long."  }
            return nil
        }

        // the loop has saturated, but instances are satisfiable
        return true
    }
}
