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
      typealias LiteralIndex = Int
      typealias LiteralReference = Pair<ClauseReference, LiteralIndex>

     private var clauses = Array<Clause>()
     private var triples = Array<Yices.Tuple>()

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
     private var registeredClauseReferences = Dictionary<term_t, Set<ClauseReference>>()
     var count: Int { return clauses.count }

     /// map leaf paths to literal, i.e. pairs of clauses and selected literals
     private var registeredLiteralReferences = TrieClass<SymHop<N.Symbol>, LiteralReference>()

     private func clause(literalReference: LiteralReference) -> Clause {
         let (clauseReference, _) = literalReference.values
         return clauses[clauseReference]
     }

     private func literal(literalReference: LiteralReference) -> Literal {
         let (clauseReference, literalIndex) = literalReference.values
         return clauses[clauseReference].nodes![literalIndex]
     }

     private func yicesLiteral(literalReference: LiteralReference) -> term_t {
         let (clauseReference, literalIndex) = literalReference.values
         return triples[clauseReference].literals[literalIndex]
     }

     private func register(literalReference: LiteralReference) {
         for path in literal(literalReference:literalReference).leafPaths {
             let _ = registeredLiteralReferences.insert(literalReference, at:path)
         }
     }

     private func deregister(literalReference: LiteralReference) {
         for path in literal(literalReference:literalReference).leafPaths {
             let _ = registeredLiteralReferences.remove(literalReference, at:path)
         }
     }

     /// search for a literal of a clause that holds in model
     private func selectLiteral(clauseReference: ClauseReference,
     consider: @autoclosure (term_t) -> Bool = true ,
     model: Yices.Model) -> LiteralReference? {
         let (_, literals, shuffled) = triples[clauseReference]

         guard let t = shuffled.first(where: { consider($0) && model.implies(formula:$0) }),
         let idx = literals.index(of:t) else {
              Syslog.error { "\(literals),\(shuffled) do not hold in model" }
              return nil
         }

         return LiteralReference(clauseReference, idx)
    }

    /// referenced yices literal and its valuation in model
    private func validate(literalReference: LiteralReference,
    model: Yices.Model) -> (term_t, Bool) {
        let t = yicesLiteral(literalReference: literalReference)
        return (t, model.implies(formula: t))
    }

    private func insert(clause: N, triple: Yices.Tuple) -> ClauseReference {
        assert(clauses.count == triples.count)

        let clauseReference = clauses.count

        clauses.append(clause)
        triples.append(triple)

        if registeredClauseReferences[triple.clause]?.insert(clauseReference) == nil {
            registeredClauseReferences[triple.clause] = Set(arrayLiteral: clauseReference)
        }

        return clauseReference

    }

     /// insert a normalized copy of the clause if no variant is allready there
     func insert(clause: N) -> (inserted: Bool, referenceAfterInsert: ClauseReference) {

         let newClause = clause.normalized(prefix:"V")
         let newTriple = Yices.clause(newClause)

         if let clauseReference = registeredClauseReferences[newTriple.clause]?.first(where: {
             newClause == clauses[$0]
             }) {
             return (false, clauseReference)
        }

         return (true, insert(clause:newClause, triple:newTriple))
    }
 }
