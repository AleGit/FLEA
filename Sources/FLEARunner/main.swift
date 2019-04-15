import Foundation

@testable import FLEA

Syslog.openLog(options: .console, .pid, .perror)
let logLevel = Syslog.maximalLogLevel
_ = Syslog.setLogMask(upTo: logLevel)
defer {
    Syslog.closeLog()
}

private final class TheNode: SymbolNameTyped, SymbolTabulating, Sharing, Node,
    ExpressibleByStringLiteral {
    typealias S = Int
    typealias N = TheNode

    static var symbols = IntegerSymbolTable<S>() // protocol SymbolTabulating
    static var pool = WeakSet<N>() // protocol Sharing
    // var folks = WeakSet<N>()                  // protocol Kin

    var symbol: S = -1 // N.symbolize(name: Tptp.wildcard, type: .variable) -> -1
    var nodes: [N]? // protocol Node

    var description: String { // protocol Node : CustomStringConvertible
        return defaultDescription
    }

    lazy var hashValue: Int = self.defaultHashValue // protocol Node : Hashable
}

// MARK: functions
func process(problem: String) {

    Syslog.debug { "Hello, \(problem)" }

    guard let theProver = FLEA.ProverY<TheNode>(problem: problem) else {
        Syslog.warning { "Could not create prover with problem \(problem)" }
        return
    }
    print(problem, theProver.clauseCount, theProver.insuredClausesCount)

    let (result, runtime) = utileMeasure {
        theProver.run(timeout: 60.0)
    }

    print("\(result)", runtime, "clauses:", theProver.clauseCount,
          "ensured:", theProver.insuredClausesCount)
}

_ = Demo.demo()

// ============================================================/

let options = CommandLine.options

for (key, value) in options {
    print(key, value)
}

if let problems = options["--problem"] {

    Yices.setUp()
    defer { Yices.tearDown() }

    for problem in problems {
        print("Problem:\(problem)")
        process(problem: problem)
    }
}
