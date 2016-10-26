//  Copyright © 2016 Alexander Maringele. All rights reserved.

import CYices

protocol ClauseCollection {
    associatedtype Clause
    associatedtype Literal
    associatedtype ClauseReference : Hashable
    associatedtype LiteralReference : Hashable

    func insert(clause: Clause) -> (inserted:Bool, referenceAfterInsert: ClauseReference)
}

final class Clauses<N:Node> : ClauseCollection
  where N:SymbolStringTyped {
      typealias Clause = N
      typealias Literal = N
      typealias ClauseReference = Int
      typealias LiteralReference = Pair<ClauseReference, Int>

     private var clauses = Array<Clause>()

     /// map yices clauses of type `term_t` to tptp clauses of type `Node``
     /// for fast variant candidates retrieval.
     /// 
     /// Let F be the clause p(A)|q(B). Then the clauses
     /// - p(X)|q(Y), a (structural) variant with renaming [A→Y,B→X]
     /// - p(X)|q(X), a (structural) non-proper instance with variable substitution [A→X,B→X]
     /// - q(X)|p(Y), a variant with q(X)|p(Y)≣p(Y)|q(X) and renaming [A→Y,B→X]
     /// - p(X)|q(Y)|q(Z), a generalization with variable substitution [X→A, Y→B, Z→B])
     /// are ingorable for satisfiability and their corresponding yices terms are equivalent to p(_)|q(_).

     /// Let G be the clause p(A)|q(A). Then the clauses
     /// - p(X)|q(Y), a generalization of G with [X→A, Y→B]
     /// - p(X)|q(Y)|q(Z), a generalization of G with [X→A, Y→B, Y→C]
     /// is not ignorable, but their corresponding yices terms are equivalent to p(_)|q(_),
     /// but these cases will not occur.
     private var clauseVariantCandidates = Dictionary<term_t, Set<ClauseReference>>()

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

         guard let candidates = clauseVariantCandidates[yicesClause] else {
             // there are no candidates for variants
             clauseVariantCandidates[yicesClause] = Set(arrayLiteral: newIndex)
             clauses.append(newClause)
             return (true, newIndex)
         }

         if let index = candidates.first(where: { newClause == clauses[$0]}) {
             // a variant was found (variants must be equal because of normalization)
             return (false, index)
         }

         // a new clause
         clauseVariantCandidates[yicesClause]?.insert(newIndex)
         clauses.append(newClause)
         return (true, newIndex)
    }
 }