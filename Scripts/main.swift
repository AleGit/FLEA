import Foundation

Syslog.openLog(options:.console, .pid, .perror)
let logLevel = Syslog.maximalLogLevel
let _ = Syslog.setLogMask(upTo:logLevel)
defer {
    Syslog.closeLog()
}

private final class TheNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias S = Int
    typealias N = TheNode
    static var symbols = StringIntegerTable<S>()    // protocol SymbolTabulating
    static var pool = WeakSet<N>()                  // protocol Sharing
    // var folks = WeakSet<N>()                  // protocol Kin

    var symbol: S = N.symbolize(string:Tptp.wildcard, type:.variable)
    var nodes: [N]? = nil                           // protocol Node

    var description: String {                       // protocol Node : CustomStringConvertible
        return defaultDescription
    }

    lazy var hashValue: Int = self.defaultHashValue // protocol Node : Hashable
  }



fileprivate typealias TheProver = FLEA.ProverY<TheNode, YicesContext>
// MARK: functions
func process(problem: String) {

    Syslog.debug { "Hello, \(problem)" }

    guard let theProver = TheProver(problem:problem) else {
        Syslog.warning { "Could not create prover with problem \(problem)" }
          return
      }
      print(problem, theProver.clauseCount, theProver.insuredClausesCount)

    let (result, runtime) = utileMeasure {
        theProver.run(timeout:60.0)
    }

    print(result, runtime, "clauses:", theProver.clauseCount,
    "ensured:", theProver.insuredClausesCount)

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
