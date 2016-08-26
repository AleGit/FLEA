import Foundation

protocol Prover {

}


// πρῶτος
final class ΠρῶτοςProver<N:Node> : Prover
where N:SymbolStringTyped, N.Symbol == Int {
    typealias ClauseTuple = (String,Tptp.Role,N)
    typealias AxiomFileTriple = (String,[String],URL)

    let problem : (String,URL)
    var clauses : [ClauseTuple]
    var includes : [AxiomFileTriple]

    var names : TrieClass<Character,Int>
    var roles : Dictionary<Tptp.Role, Set<Int>>
    var sizes : [Set<Int>]

    var literalsTrie = TrieClass<Int,Int>()

    /// initialize the prover with a problem, i.e.
    /// - read all the clauses from the file
    /// - read all the includes from the file
    ///   but not read the clauses from the includes
    /// - create an (empty) index structure 
    ///   for selected literals of processed clauses
    /// - create an (empty) index structure
    ///   for processed clauses
    /// - create a mapping from names to clauses (1:n) where n >=1 
    /// - create a mapping from roles to clauses (1:n) where n >= 0
    init?(problem name:String) {
        guard let (url,file) = urlFile(name:name) else { return nil }
        problem = (name, url)
        // includes = extractIncludeTriples(from:file, url:url)
        includes = file.includeSelectionURLTriples(url:url)
        // clauses = extractClauseTriples(from:file)
        clauses = file.nameRoleClauseTriples()
        (names,roles,sizes) = collectNamesRolesSizes(clauses)

        helloWorld()
        Syslog.info { "with \(name)) was successful." }
    }

    func helloWorld() {
        Syslog.info { "Hello World" }
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

// MARK: helper functions

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

private func collectNamesRolesSizes<T:Node>(_ array:[(name:String,role:Tptp.Role,node:T)] ) 
-> (TrieClass<Character,Int>, [Tptp.Role : Set<Int>], [Set<Int>]) {
    var names = TrieClass<Character,Int>() // [String:Set<Int>]()
    var roles = Dictionary<Tptp.Role,Set<Int>>()
    var sizes = Array<Set<Int>>()
    for (index,element) in array.enumerated() {
        let (name,role,node) = element

        names.insert(index, at:name.characters)
        if roles[role]?.insert(index) == nil {
            roles[role] = Set(arrayLiteral:index)
        }
        if let count = node.nodes?.count {
            while sizes.count <= count {
                sizes.append(Set<Int>())
            }
            sizes[count].insert(index)

        }
        else {
            let message = "A variable \(node) is not a literal"
            Syslog.error { message }
            assert(false, message )
        }
    }
    return (names,roles,sizes)
}




