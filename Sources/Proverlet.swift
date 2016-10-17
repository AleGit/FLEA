final class Proverlet<N:Node>: Prover {
    init?(problem name: String) {
        Syslog.fail() { "MISSING IMPLEMENTATION" }
        return nil
    }

    func run(timeout: TimeInterval) -> Bool? {
        Syslog.fail { "MISSING IMPLEMENTATION" }
        return nil
    }

    var fileCount: Int {
        Syslog.fail { "MISSING IMPLEMENTATION" }
        return 0
    }

    var clauseCount: Int {
        Syslog.fail { "MISSING IMPLEMENTATION" }
        return 0
    }

}
