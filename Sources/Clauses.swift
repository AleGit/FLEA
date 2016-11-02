//  Copyright © 2016 Alexander Maringele. All rights reserved.

import CYices

protocol ClauseCollection {
    associatedtype Clause
    associatedtype Literal
    associatedtype ClauseReference : Hashable
    associatedtype LiteralReference : Hashable
    associatedtype Context
    // associatedtype Model

    func clause(clauseReference: ClauseReference) -> Clause
    func literal(literalReference: LiteralReference) -> Literal

    func insert(clause: Clause) -> (inserted: Bool, referenceAfterInsert: ClauseReference)
    func insure(clauseReference: ClauseReference, context: Context) -> Bool
}

final class Clauses<N:Node> : ClauseCollection
where N:SymbolStringTyped {
    typealias Clause = N
    typealias Literal = N
    typealias ClauseReference = Int
    typealias LiteralIndex = Int
    typealias LiteralReference = Pair<ClauseReference, LiteralIndex>
    // typealias Context = Yices.Context
    /// typealias Model = Yices.Model

    private var clauses = Array<Clause>()
    private var triples = Array<Yices.Tuple>()
    private var activeLiterals = Dictionary<ClauseReference, LiteralIndex>()
    private var pendingLiterals = Dictionary<ClauseReference, LiteralIndex>()

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
     private var clauseReferences = Dictionary<term_t, Set<ClauseReference>>()

     // map leaf paths to literal, i.e. pairs of clauses and selected literals
     private var literalReferences = TrieClass<SymHop<N.Symbol>, LiteralReference>()

     var count: Int { return clauses.count }

     func clause(clauseReference: ClauseReference) -> Clause {
         return clauses[clauseReference]
     }

     /// get literal by reference
     func literal(literalReference: LiteralReference) -> Literal {
         let (clauseReference, literalIndex) = literalReference.values
         return clauses[clauseReference].nodes![literalIndex]
     }

     /// get yices literal by reference
     private func yicesLiteral(literalReference: LiteralReference) -> term_t {
         let (clauseReference, literalIndex) = literalReference.values
         return triples[clauseReference].literals[literalIndex]
     }

     /// acitvate a literal (that holds and all derivations have been drawn)
     private func activate(literalReference: LiteralReference) {
         let (clauseReference, literalIndex) = literalReference.values

         // an activated literal is not pending anymore
         pendingLiterals[clauseReference] = nil
         activeLiterals[clauseReference] = literalIndex

         for path in literal(literalReference:literalReference).leafPaths {
             let _ = literalReferences.insert(literalReference, at:path)
         }
     }

     /// deactivate a literal (that does not hold anymore)
     private func deactivate(literalReference: LiteralReference) {
         for path in literal(literalReference:literalReference).leafPaths {
             let _ = literalReferences.remove(literalReference, at:path)
         }

         let (clauseReference, _) = literalReference.values
         activeLiterals[clauseReference] = nil
     }

     /// find a literal of a clause that holds
     private func selectLiteral(clauseReference: ClauseReference,
     selectable: (term_t) -> Bool = { _ in true }, // by default all literals are selectable
     model: Yices.Model) -> LiteralIndex? {
         let (_, literals, shuffled) = triples[clauseReference]

         guard
         // find a liteal term that holds in the model
         let t = shuffled.first(where: {
             selectable($0) // by default every literal term is considered
             && model.implies(formula:$0) // that holds in the model
             }),
         // get the index of the liteal term thats holds in the model
         let idx = literals.index(of:t) else {
              Syslog.error { "\(literals),\(shuffled) do not hold in model" }
              return nil
         }

         return idx
    }

    /// check if a literal still holds
    private func validate(literalReference: LiteralReference,
    model: Yices.Model) -> (term_t, Bool) {
        let t = yicesLiteral(literalReference: literalReference)
        return (t, model.implies(formula: t))
    }

    /// append and register an allready _normalized_ and _encoded_ clause to collectctions
    private func append(clause: N, triple: Yices.Tuple) -> ClauseReference {
        assert(clauses.count == triples.count)

        let clauseReference = clauses.count

        clauses.append(clause)
        triples.append(triple)

        // add or update mapping from yices clause to (tptp) clause referneces
        if clauseReferences[triple.clause]?.insert(clauseReference) == nil {
            clauseReferences[triple.clause] = Set(arrayLiteral: clauseReference)
        }

        return clauseReference
    }

     /// insert the normalized copy of the clause if no variant is allready there
     func insert(clause: N) -> (inserted: Bool, referenceAfterInsert: ClauseReference) {

         let newClause = clause.normalized(prefix:"V")
         let newTriple = Yices.clause(newClause)

         // find first variant of given clause

         if let clauseReference = clauseReferences[newTriple.clause]?.first(where: {
             newClause == clauses[$0]
             }) {
             return (false, clauseReference)
        }

        // no variant of given clause was found

         return (true, append(clause:newClause, triple:newTriple))
    }

    func clashingLiterals(literalReference: LiteralReference) -> Set<LiteralReference>? {
        guard let negatedLiteral = self.literal(literalReference: literalReference).negated else {
            return nil
        }
        let wildcard = negatedLiteral.joker

        return literalReferences.unifiables(paths: negatedLiteral.leafPaths,
        wildcard: SymHop.symbol(wildcard))



    }


    func insure(clauseReference: ClauseReference, context: Yices.Context) -> Bool {
        let (yicesClause, _, _) = triples[clauseReference]

        guard context.insure(clause: yicesClause), let model = Yices.Model(context: context) else {
            return false // not satisfiable
        }
        // context is satisfiable and a model was constructed

        pendingLiterals[clauseReference] = selectLiteral(
            clauseReference:clauseReference, model: model)

        for (clauseReference, literalIndex) in activeLiterals {
            let literalReference = LiteralReference(clauseReference, literalIndex)

            let (term, holds) = validate(
                literalReference:literalReference,
                model:model
            )

            if holds { continue }

            deactivate(literalReference: literalReference)

            pendingLiterals[clauseReference] = selectLiteral(
                clauseReference: clauseReference,
                selectable: { $0 != term }, // ignore previously checked yices literal
                model: model )
        }

        return true
    }
 }
