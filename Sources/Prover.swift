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

    func process(clause index:Int) -> Bool {
        defer { processed.insert(index) }

        let (name,role,clause) = clauses[index]

        Syslog.debug { "#\(index): Processing' \(name)' '\(role)' '\(clause)'" }

        let (yClause,yLiterals,_) = Yices.clause(clause)

        guard isNotIndicated(yLiterals:yLiterals) else {
            Syslog.notice { "Clause \(index) ignored."  }
            ignored.insert(index)
            // nothing has changed
            return true
        }

        guard context.assert(clause:yClause) == true, 
        let model = Yices.Model(context:context) else {
            // not satisfaible, no model
            return false
        }

        indicate(clause:index, yLiterals:yLiterals)

        Syslog.info { "Clause \(index) activated."  }

        var sli : Int?

        for (tidx,t) in yLiterals.enumerated() {

            if model.implies(t:t) {
                Syslog.notice {
                    "\(clause) \(clause.nodes![tidx]) \(index).\(tidx)"
                }
                sli = tidx    
                break            
            }
        }

        guard let selected = sli else {
            Syslog.error { "Satisfiable context, but no literal did hold?" }
            assert(false)
            return false // not satisfiable
        }

        guard let literal = clause.nodes?[selected] else {
            Syslog.error { "Selected literal does not exist" }
            assert(false)
            return false
        }

        yTuples[index] = (yClause,yLiterals,selected)

        
        print("=== \(index).\(selected): \(literal) \(clause) ===")
    

        let (leafPaths,negatedPaths) = literal.leafPathsPair

        // search clashing selected literals

/*
        if let candidates = literalsTrie.candidates(from:negatedPaths) {
            print("hi ############")
        }
*/
       //  Syslog.error { "\(index).\(selected) may clash with \(candidates)"}

       var candidates = processed.subtracting(ignored) // all

       for path in negatedPaths {
           guard let cs = literalsTrie.candidates(from:path) else {
               candidates = Set<Int>()
               continue;
           }
           candidates.formIntersection(cs)
       }





        /// map selected literal leaf paths to clause index
        for path in leafPaths {
            literalsTrie.insert(index, at:path)
        }




        return true // still satisfiable
        
        
      

    }

    func isNotIndicated<S:Sequence>(yLiterals:S) -> Bool 
    where S.Iterator.Element == term_t {
        var candidates = processed.subtracting(ignored)
        for t in Set(yLiterals) {
            guard let s = literal2clauses[t],
            !s.isEmpty else {
                return true
            }
            candidates.formIntersection(s)
            Syslog.debug {
                "\(t) \(s) \(candidates)"
            }
            if candidates.isEmpty { return true }
        }
        return false
    }

    func indicate<S:Sequence>(clause index: Int, yLiterals: S) 
     where S.Iterator.Element == term_t {
         for t in yLiterals {
             if literal2clauses[t]?.insert(index) == nil {
                 literal2clauses[t] = Set(arrayLiteral:index)
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


