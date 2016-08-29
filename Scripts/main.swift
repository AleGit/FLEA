Syslog.openLog(options:.console,.pid,.perror)
let logLevel = Syslog.maximalLogLevel
let _ = Syslog.setLogMask(upTo:logLevel)
defer {
    Syslog.closeLog()
}




// MARK: functions
func process(problem:String) {
    if let prover = ΠρῶτοςProver<Tptp.KinIntNode>(problem:problem) {
        print(Tptp.KinIntNode.pool.count)
        print(prover.clauses.count,prover.includes.count)
    }
}

// ============================================================/

let options = CommandLine.options
if let problems = options["--problem"] {
    for problem in problems {
        process(problem:problem)

    }
}

let _ = Demo.demo()

// ============================================================/