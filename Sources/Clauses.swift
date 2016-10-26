//  Copyright © 2016 Alexander Maringele. All rights reserved.

import CYices

protocol ClauseCollection {
    associatedtype Clause
    associatedtype Literal
    associatedtype ClauseReference : Hashable
    associatedtype LiteralReference : Hashable

    func insert(clause: Clause) -> (inserted:Bool, referenceAfterInsert: ClauseReference)
}

extension Pair {
    var clauseReference: T { return values.0 }
    var literalReference: U { return values.1 }
}

final class Clauses<N:Node> : ClauseCollection
  where N:SymbolStringTyped {
      typealias Clause = N
      typealias Literal = N
      typealias ClauseReference = Int
      typealias LiteralReference = Pair<ClauseReference, Int>


     private var clauses = Array<Clause>()

     /// map yices clauses to tptp clauses
     /// - variants of tptp clauses will be encoded to the same yices term
     /// - variable renamings of tptp clauses too
     /// tptp clauses with the same encoding could be variants
     private var clauseVariants = Dictionary<term_t, Set<ClauseReference>>()

     /// map leaf paths to literal, i.e. pairs of clauses and selected literals
     private var selectedLiteralsTrie = TrieClass<SymHop<N.Symbol>, LiteralReference>()

     private func clause(byLiteralReference reference:LiteralReference) -> Clause {
         return clauses[reference.values.0]
     }

     private func literal(byLiteralReference reference:LiteralReference) -> Literal {
         return clauses[reference.values.0].nodes![reference.values.1]
     }

     private func select(literalReference reference: LiteralReference) {
         for path in literal(byLiteralReference:reference).leafPaths {
             selectedLiteralsTrie.insert(reference, at:path)
         }
     }
     private func deselect(literalReference reference: LiteralReference) {
         for path in literal(byLiteralReference:reference).leafPaths {
             selectedLiteralsTrie.remove(reference, at:path)
         }
     }



     var count: Int { return clauses.count }

     /// insert a normalized copy of the clause if no variant is allready there
     func insert(clause: N) -> (inserted: Bool, referenceAfterInsert: Int) {

         let newClause = clause.normalized(prefix:"X")
         let newIndex = clauses.count
         let (yicesClause, yicesLiterals, shuffledYicesLiterals) = Yices.clause(newClause)

         guard let candidates = clauseVariants[yicesClause] else {
             // there are no candidates for variants
             clauseVariants[yicesClause] = Set(arrayLiteral: newIndex)
             clauses.append(newClause)
             return (true, newIndex)
         }

         if let index = candidates.first(where: { newClause == clauses[$0]}) {
             // a variant was found (variants must be equal because of normalization)
             return (false, index)
         }

         // a new clause
         clauseVariants[yicesClause]?.insert(newIndex)
         clauses.append(newClause)
         return (true, newIndex)
    }
 }