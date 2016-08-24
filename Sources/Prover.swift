import Foundation

// πρῶτος
struct ΠρῶτοςProver<N:Node> 
where N:SymbolStringTyped {

    typealias ClauseTuple = (String,String,N)
    let problem : (String,URL)
    var clauses : [ClauseTuple]
    var includes : [(String,[String])]

    /// initialize the prover with a problem, i.e.
    /// - read all the clauses from the file
    /// - read all the includes from the file
    ///   but not read the clauses from the includes
    /// - create an (empty) index structure 
    ///   for selected literals of processed clauses
    /// - create an (empty) index structure
    ///   for processed clauses
    init?(problem:String) {
        guard let url = URL(fileURLwithProblem:problem) else {
            Syslog.error { "Problem \(problem) could not be found." }
            return nil
        }
        guard let file = Tptp.File(url:url) else {
            Syslog.error { "Problem \(problem) at \(url.path) could not be read and parsed." }
            return nil
        }
        self.problem = (problem, url)

        self.clauses = file.cnfs.flatMap {
            guard let name = $0.symbol,
            let child = $0.child, 
            let role = child.symbol,
            let cnf = child.sibling else {
                Syslog.error { "invalid input file \(problem) \(url)"}
                return nil
            }
            return (name,role,N(tree:cnf))
        }

        self.includes = file.includes.flatMap {
            guard let file = $0.symbol else {
                return nil
            }
            let selection = $0.children.flatMap {
                $0.symbol
            }
            return (file,selection)
        }




    }

}