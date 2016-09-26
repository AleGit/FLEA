import Foundation
import CYices

final class ProverY<N:Node>: Prover
where N:SymbolStringTyped {
    var clauses: Array<(String, Tptp.Role, N)>

    var files = Array<(String, URL, Int, Int)>()

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
    }
}

extension ProverY {
    func run(timeout: AbsoluteTime) -> Bool? {
        guard let name = files.first?.0 else {
            Syslog.error { "Problem is empty" }
            return true
        }
        Syslog.info { "\(name) timeout = \(timeout) s" }


        return nil
    }
}