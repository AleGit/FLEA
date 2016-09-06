import Foundation

Syslog.openLog(options:.console,.pid,.perror)
let logLevel = Syslog.maximalLogLevel
let _ = Syslog.setLogMask(upTo:logLevel)
defer {
    Syslog.closeLog()
}




// MARK: functions
func process(problem:String) {
    
    let name = problem
//     let options = CommandLine.options
// if let problems = options["--problem"] {
//     for name in problems {

        print("xProblem:\(name)")
    guard let url = URL(fileURLwithProblem:name) else {
        Syslog.error { "Problem \(name) could not be found." }
        return
    }
    guard let file = Tptp.File(url:url) else {
        Syslog.error { "Problem \(name) at \(url.path) could not be read and parsed." }
        return
    }

    let array = file.cnfs.map {
        Tptp.KinIntNode(tree:$0)
        }

    print(array.count)

    print(file.path)

    if let prover = ΠρῶτοςProver<Tptp.KinIntNode>(problem:problem) {
        print(Tptp.KinIntNode.pool.count)
        print(prover.clauses.count,prover.includes.count)
    }

//     }
// }
}

// ============================================================/

let options = CommandLine.options
if let problems = options["--problem"] {
    for problem in problems {
        print("Problem:\(problem)")
        process(problem:problem)

    }
}

let _ = Demo.demo()

// ============================================================/