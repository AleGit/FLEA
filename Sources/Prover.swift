import Foundation

struct Prover<N:Node> 
where N:SymbolStringTyped {

    typealias Clause = (String,String,N)
    let problem : (String,URL)
    var clauses : [Clause]
    var includes : [N]
    
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

        self.includes = file.includes.map {
            N(tree:$0)
        }




    }

}