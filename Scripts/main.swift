import Foundation

Syslog.openLog(options:.console, .pid, .perror)
let logLevel = Syslog.maximalLogLevel
let _ = Syslog.setLogMask(upTo:logLevel)
defer {
    Syslog.closeLog()
}

private final class TheNode: SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node,
  ExpressibleByStringLiteral {
    typealias S = Int
    typealias N = TheNode
    static var symbols = StringIntegerTable<S>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()

    var symbol: S = N.symbolize(string:Tptp.wildcard, type:.variable)
    var nodes: [N]? = nil

    var description: String { return defaultDescription }

    lazy var hashValue: Int = self.defaultHashValue
  }



// MARK: functions
func process(problem: String) {

    Syslog.debug { "Hello, \(problem)" }

    guard let theProver = FLEA.ProverY<TheNode>(problem:problem) else {
        Syslog.warning { "Could not create prover with problem \(problem)" }
          return
      }
      print(problem, theProver.clauses.count, theProver.insuredClausesCount)

    let (result, runtime) = utileMeasure {
        theProver.run(timeout:60.0)
    }

    print(result, runtime, theProver.clauses.count, theProver.insuredClausesCount)

}
let _ = Demo.demo()

// ============================================================/

let options = CommandLine.options
if let problems = options["--problem"] {

    Yices.setUp()
    defer { Yices.tearDown() }

    for problem in problems {
        print("Problem:\(problem)")
        process(problem:problem)
    }
}
