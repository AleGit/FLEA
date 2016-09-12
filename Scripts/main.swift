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
    guard let url = URL(fileURLWithProblem:name) else {
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

    let includes = file.includeSelectionURLTriples(url:url)
    let clauses : [(String,Tptp.Role,Tptp.KinIntNode)] = file.nameRoleClauseTriples()

    print(array.count,clauses.count,includes.count)

    print(file.path)

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