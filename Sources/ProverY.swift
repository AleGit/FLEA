import Foundation
import CYices

final class ProverY<N:Node>: Prover {
    var clauses = [N]()

    var files = Array<(String, URL, Tptp.File)>()

    init?(problem name: String) {
        Syslog.info { "problem name = \(name)" }

        guard let (url, file) = ProverY.URLAndFile(problem: name) else { return nil }

        files.append((name, url, file))


    }

    func run(timeout: AbsoluteTime) -> Bool? {
        guard let name = files.first?.0 else {
            Syslog.error { "Problem is empty" }
            return true
        }
        Syslog.info { "\(name) timeout = \(timeout) s" }


        return nil
    }


}
