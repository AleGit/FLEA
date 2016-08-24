import Foundation


// πρῶτος
struct ΠρῶτοςProver<N:Node> 
where N:SymbolStringTyped, N.Symbol == Int {
    typealias ClauseTuple = (String,String,N)

    typealias AxiomFileTriple = (String,URL,[String])
    let problem : (String,URL)
    var clauses : [ClauseTuple]
    var includes : [AxiomFileTriple]

    var literalsTrie = TrieClass<Int,Int>()


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
                assert(false)
                return nil
            }
            return (name,role,N(tree:cnf))
        }

        self.includes = file.includes.flatMap {
            guard let file = $0.symbol,
            let axiomURL = URL(fileURLwithAxiom:file,
            problemURL:url) else {
                Syslog.error { "Axiom file was not found."}
                assert(false)
                return nil
            }
            let selection = $0.children.flatMap {
                $0.symbol
            }
            return (file,axiomURL,selection)
        }

        Syslog.info {
            "Prover(problem:\(problem)) was successful."
        }
    }

    func run(timeout:AbsoluteTime = 5.0) {
        let endtime = AbsoluteTimeGetCurrent() + timeout
        Syslog.info { "timeaout after \(timeout) seconds." }
        

        let (_,runtimes) = utileMeasure {
            while AbsoluteTimeGetCurrent() < endtime {
                sleep(1)
                print(AbsoluteTimeGetCurrent())

                // select clause
                // process clause
                // select literal
                // search clashes
                // insert clauses
                // insert indices


            }
        }
        Syslog.info { "runtimes = \(runtimes)" }
    }
}

