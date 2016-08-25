import Foundation

protocol Prover {

}

private func urlFile(name:String) -> (URL,Tptp.File)? {
    guard let url = URL(fileURLwithProblem:name) else {
        Syslog.error { "Problem \(name) could not be found." }
        return nil
    }
    guard let file = Tptp.File(url:url) else {
        Syslog.error { "Problem \(name) at \(url.path) could not be read and parsed." }
        return nil
    }
    return (url,file)
}

private func collectNamesAndRoles<T>(_ array:[(name:String,role:Tptp.Role,node:T)] ) -> (TrieClass<Character,Int>, [Tptp.Role:Set<Int>]) {
    var names = TrieClass<Character,Int>() // [String:Set<Int>]()
    var roles = Dictionary<Tptp.Role,Set<Int>>()
    for (index,element) in array.enumerated() {
        let (name,role,_) = element

        names.insert(index, at:name.characters)
        if roles[role]?.insert(index) == nil {
            roles[role] = Set(arrayLiteral:index)
        }
    }
    return (names,roles)
}

private func extractClauseTriples<N:Node>(from file:Tptp.File) -> [(String,Tptp.Role,N)] 
where N:SymbolStringTyped {
    return file.cnfs.flatMap {
        guard let name = $0.symbol,
        let child = $0.child, 
        let string = child.symbol,
        let role = Tptp.Role(rawValue:string),
        let cnf = child.sibling else {
            let symbol = $0.symbol ?? "n/a"
            Syslog.error { "Invalid cnf \(symbol) in \(file.path)"}
            assert(false,"Invalid cnf in \(symbol) in \(file.path)")
            return nil
        }
        return (name,role,N(tree:cnf))
    }
}

private func extractIncludeTriples(from file:Tptp.File, url:URL) -> [(String,URL,[String])] {
    return file.includes.flatMap {
        guard let file = $0.symbol,
        let axiomURL = URL(fileURLwithAxiom:file,problemURL:url) else {
            let symbol = $0.symbol ?? "'n/a'"
            Syslog.error { "Include file \(symbol) was not found."}
            assert(false, "Include file \(symbol) was not found.")
            return nil
        }
        let selection = $0.children.flatMap {
            $0.symbol
        }
        return (file,axiomURL,selection)
    }
}


// πρῶτος
struct ΠρῶτοςProver<N:Node> : Prover
where N:SymbolStringTyped, N.Symbol == Int {
    typealias ClauseTuple = (String,Tptp.Role,N)
    typealias AxiomFileTriple = (String,URL,[String])

    let problem : (String,URL)
    var clauses : [ClauseTuple]
    var includes : [AxiomFileTriple]

    var literalsTrie = TrieClass<Int,Int>()

    // var names : [String:Set<Int>]
    var names = TrieClass<Character,Int>()
    var roles : [Tptp.Role:Set<Int>]

    /// initialize the prover with a problem, i.e.
    /// - read all the clauses from the file
    /// - read all the includes from the file
    ///   but not read the clauses from the includes
    /// - create an (empty) index structure 
    ///   for selected literals of processed clauses
    /// - create an (empty) index structure
    ///   for processed clauses
    init?(problem name:String) {
        guard let (url,file) = urlFile(name:name) else { return nil }
        problem = (name, url)
        clauses = extractClauseTriples(from:file)
        includes = extractIncludeTriples(from:file, url:url)
        (names,roles) = collectNamesAndRoles(clauses)
        Syslog.info { "with \(name)) was successful." }
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

