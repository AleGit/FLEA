import Foundation
import CYices

protocol Prover {

}


// πρῶτος
final class ΠρῶτοςProver<N:Node> : Prover
where N:SymbolStringTyped, N.Symbol == Int {
    typealias ClauseTuple = (String,Tptp.Role,N)

    /* *** postpone until after talk *** */
    typealias AxiomFileTriple = (String,[String],URL)

    /// store name and file URL of problem
    let problem : (String,URL)

    /// store names, roles and clauses
    var clauses : [ClauseTuple]

    /// store names, selections, and file URL of includes
    var includes : [AxiomFileTriple]

    /* *** postpone until after talk *** */
    /// map names to clauses, usually 1:1
    var names = TrieClass<Character,Int>()

    /* *** postpone until after talk *** */
    /// map roles to clauses, 1:n
    var roles = Dictionary<Tptp.Role, Set<Int>> ()

    /* *** postpone until after talk *** */
    /// map sizes (number of literals) to clauses
    var sizes = [Set<Int>]()

    /// map literal paths to clauses
    var literalsTrie = TrieClass<Int,Int>()

    /// map *term_t* literals to clauses 
    var literal2clauses = Dictionary<term_t, Set<Int>>()

    /// map clausses to *term_t* literals
    var clause2literals = Dictionary<Int,[term_t]>()

    /// collect processed clauses
    var processed = Set<Int>()
    var ignored = Set<Int>() // subset of processed

    var context = Yices.Context()
    var yTuples = Dictionary<Int,(term_t,[term_t],Int)>()
    

    /// initialize the prover with a problem, i.e.
    /// - read all the clauses from the file
    /// - read all the includes from the file
    ///   but do not read the clauses from the includes
    /// - create an (empty) index structure 
    ///   for selected literals of processed clauses
    /// - create an (empty) index structure
    ///   for processed clauses
    /// - create a mapping from names to clauses (1:n) where n >=1 
    /// - create a mapping from roles to clauses (1:n) where n >= 0
    init?(problem name:String) {
        guard let (url,file) = urlFile(name:name) else { return nil }
        problem = (name, url)
        includes = file.includeSelectionURLTriples(url:url)
        clauses = file.nameRoleClauseTriples()
        Syslog.info { "with \(name)) was successful." }
    }


    func selectClause() -> Int {
        return processed.count
    }

    /* *** postpone until after talk *** */
    func collect() {
        for (index,element) in clauses.enumerated() {
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
    }

    func run(timeout:AbsoluteTime = 5.0) -> Bool? {
        let endtime = AbsoluteTimeGetCurrent() + timeout
        Syslog.info { "timeaout after \(timeout) seconds." }

        let (result,runtimes) = utileMeasure {
            () -> Bool? in
            while processed.count < clauses.count 
            {
                guard AbsoluteTimeGetCurrent() < endtime else { 
                    // Don't know (timeout)
                    return nil 
                }

                let index = selectClause()
                guard process(clause:index) else {
                    return false // Unsatisfiable
                }
            }

            // Saturated
            return true // Satisfiable
        }
        Syslog.info { "runtimes = \(runtimes)" }
        return result
    }

    func selectLiteral(with model: Yices.Model, yicesLiterals:[term_t]) -> Int {
        for (literalIndex, yicesLiteral) in yicesLiterals.enumerated() {
            if model.implies(t:yicesLiteral) {
                return literalIndex
            }
        }
        assert(false,"\(#function) model implies none of the literals.")
        return -1
    }

    func reselectLiterals(with model: Yices.Model) {
        for (clauseIndex,triple) in yTuples {
            let (_,_,tptpClause) = clauses[clauseIndex]
            let (yicesClause,yicesLiterals,selectedLiteralIndex) = triple

            if !model.implies(t:yicesLiterals[selectedLiteralIndex]) {

                let tptpLiterals = tptpClause.nodes!

                for path in tptpLiterals[selectedLiteralIndex].leafPaths {
                    let _ = literalsTrie.remove(clauseIndex, at:path)
                }

                let selected = selectLiteral(with:model, yicesLiterals:yicesLiterals)

                for path in tptpLiterals[selected].leafPaths {
                    literalsTrie.insert(clauseIndex, at:path)
                }
                yTuples[clauseIndex]?.2 = selected

                Syslog.debug { "\(clauseIndex).\(selected) '\(tptpClause)' reselected !!!."}
                continue
            }
        }
    }

    func process(clause index:Int) -> Bool {
        defer { processed.insert(index) }

        let (_,_,tptpClause) = clauses[index]
        let (yicesClause,yicesLiterals,_) = Yices.clause(tptpClause)

        guard isNotIndicated(yicesLiterals:yicesLiterals) else {
            ignored.insert(index)
            Syslog.info { "\(index) '\(tptpClause)' ignored."}
            // nothing has changed
            return true
        }

        guard context.insure(clause:yicesClause), 
        let model = Yices.Model(context:context) else {
            // not satisfaible, no model
            return false
        }
        
        reselectLiterals(with:model)

        indicate(clause:index, yicesLiterals:yicesLiterals)
        
        let selected = selectLiteral(with:model, yicesLiterals:yicesLiterals)
        let tptpLiteral = tptpClause.nodes![selected]

        yTuples[index] = (yicesClause,yicesLiterals,selected)
        
        Syslog.debug { "\(index).\(selected) '\(tptpClause)' activated."}
        
        let (leafPaths,negatedPaths) = tptpLiteral.leafPathsPair

        // search clashing selected literals

        var candidates = processed.subtracting(ignored) // all

       for path in negatedPaths {
           guard let cs = literalsTrie.candidates(from:path) else {
               candidates = Set<Int>()
               continue;
           }
           candidates.formIntersection(cs)
       }

       for candidate in candidates {
           let (candidateName,candidateRole,candidateClause) = clauses[candidate]

           let (_,yicesCandidateLiterals,selectedCandidateLiteralIndex) = yTuples[candidate]!

           let candidateLiterals = candidateClause.nodes!

           let a = tptpLiteral.unnegating
           let b = candidateLiterals[selectedCandidateLiteralIndex].unnegating

           if let mgu = (a =?= b) {

               for clause in [tptpClause,candidateClause] {
                   clauses.append(("",.unknown,clause * mgu))
               }
           }

       }

       for path in leafPaths {
           literalsTrie.insert(index, at:path)
       }




        return true // still satisfiable
        
        
      

    }

    func isNotIndicated<S:Sequence>(yicesLiterals:S) -> Bool 
    where S.Iterator.Element == term_t {
        var candidates = processed.subtracting(ignored)
        for yicesLiteral in Set(yicesLiterals) {
            guard let s = literal2clauses[yicesLiteral],
            !s.isEmpty else {
                return true
            }
            candidates.formIntersection(s)
            
            if candidates.isEmpty { return true }
        }

        return false
    }

    func indicate<S:Sequence>(clause index: Int, yicesLiterals: S) 
     where S.Iterator.Element == term_t {
         for yicesLiteral in yicesLiterals {
             if literal2clauses[yicesLiteral]?.insert(index) == nil {
                 literal2clauses[yicesLiteral] = Set(arrayLiteral:index)
             }
         }
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


