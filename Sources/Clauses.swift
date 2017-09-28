//  Copyright © 2017 Alexander Maringele. All rights reserved.

import CYices

/// manage and access clauses and literal by reference
protocol ClauseCollection {
    associatedtype Clause
    associatedtype Literal
    associatedtype ClauseReference: Hashable
    associatedtype LiteralReference: Hashable
    associatedtype Context
    // associatedtype Model

    func clause(byReference: ClauseReference) -> Clause
    var count: Int { get } // number of clauses in the collection

    func literal(byReference: LiteralReference) -> Literal

    func insert(clause: Clause) -> (inserted: Bool, referenceAfterInsert: ClauseReference)
    func insure(clauseReference: ClauseReference, context: Context) -> Bool
}

final class Clauses<N: Node>: ClauseCollection
    where N: SymbolNameTyped {
    typealias Clause = N
    typealias Literal = N
    typealias ClauseReference = Int
    typealias LiteralIndex = Int
    typealias LiteralReference = Pair<ClauseReference, LiteralIndex>
    // typealias Context = Yices.Context
    /// typealias Model = Yices.Model

    /// all inserted clauses
    /// - clause reference is an array index
    /// - literal reference is a pair of array indices
    private var clauses = Array<Clause>()
    fileprivate var ignored = 0

    /// yices encoding for clauses
    private var yicesTuples = Array<Yices.Tuple>()

    /// within active literals all conflicts (clashes) are already considered
    private var activeLiterals = Dictionary<ClauseReference, LiteralIndex>()

    /// within pending literals and against active literals conflicts may still exist
    private var pendingLiterals = Dictionary<ClauseReference, LiteralIndex>()

    // lazy var wildcard = N.joker // '*'
    lazy var wildcardsymbol = SymHop.symbol(N.joker)

    /*
     Let F be the clause p(A)|q(B). Then the clauses
     - p(X)|q(Y), a (structural) variant with renaming [A→Y,B→X]
     - p(X)|q(X), a (structural) non-proper instance with variable substitution [A→X,B→X]
     - q(X)|p(Y), a variant with q(X)|p(Y)≣p(Y)|q(X) and renaming [A→Y,B→X]
     - p(X)|q(Y)|q(Z), a generalization with variable substitution [X→A, Y→B, Z→B])
     are ingorable for satisfiability and their corresponding yices terms are equivalent to p(_)|q(_).

     Let G be the clause p(A)|q(A). Then the clauses
     - p(X)|q(Y), a generalization of G with [X→A, Y→B]
     - p(X)|q(Y)|q(Z), a generalization of G with [X→A, Y→B, Y→C]
     is not ignorable, but their corresponding yices terms are equivalent to p(_)|q(_),
     but these cases will not occur. ?(does this hold)?
     */

    /// map yices clauses of type `term_t` to tptp clauses of type `Node``
    /// for fast variant candidates retrieval.
    private var clauseReferences = Dictionary<term_t, Set<ClauseReference>>()

    /*
     literal leaf paths:
     - literal l_1 = p(f(X,a),y, h(X)) has four leaf nodes { X, a, Y, X },
     hence it has four leaf paths: { p.1.f.1.*, p.1.f.2.a, p.2.*, p.3.h.1.* }
     - literal l_2 = p(X,Y,c) has three { { p.1.*, p.2.*, p.3.c }}
     - literal l_3 = p(X,Y,Z) has three { p.1.*, p.2.*, p.3.* }
     candidates inquiry: the intersection of unifiable literals
     p.1.* -> { p.1.f.1.*, p.1.f.2.a } -> { l_1, l_2 }
     p.2.* -> { p.2.Y } -> { l_1, l_2 }
     p.3.* -> { p.3.h.1.X } -> { l_1, l_2 }
     */

    /// map leaf paths to literals, i.e. pairs of clauses and selected literals
    /// for fast retrieval of unifiable or clashing selected literals.
    private var literalReferences = TrieClass<SymHop<N.Symbol>, LiteralReference>()

    // make protocol of derivations, i.e. pairs of processed clashing literals
    private var literalPairs = Set<Set<LiteralReference>>()

    var count: Int { return clauses.count }
    var ignoreCount: Int { return ignored }

    // get clause by reference
    func clause(byReference clauseReference: ClauseReference) -> Clause {
        return clauses[clauseReference]
    }

    /// get literal by reference
    func literal(byReference literalReference: LiteralReference) -> Literal {
        let (clauseReference, literalIndex) = literalReference.values
        return clauses[clauseReference].nodes![literalIndex]
    }

    /// get yices literal by reference
    private func yicesLiteral(byReference literalReference: LiteralReference) -> term_t {
        let (clauseReference, literalIndex) = literalReference.values
        return yicesTuples[clauseReference].literals[literalIndex]
    }

    /// acitvate a literal (that holds and all derivations have been drawn)
    func activate(literalReference: LiteralReference) {
        let (clauseReference, literalIndex) = literalReference.values

        // an activated literal is not pending anymore
        pendingLiterals[clauseReference] = nil
        activeLiterals[clauseReference] = literalIndex

        for path in literal(byReference: literalReference).leafPaths {
            _ = literalReferences.insert(literalReference, at: path)
        }
    }

    /// deactivate a literal (that does not hold anymore,
    /// which implies that the litaral cannot be pending too).
    private func deactivate(literalReference: LiteralReference) {
        for path in literal(byReference: literalReference).leafPaths {
            _ = literalReferences.remove(literalReference, at: path)
        }

        let (clauseReference, _) = literalReference.values

        activeLiterals[clauseReference] = nil
    }

    /// find a literal of a clause that holds in the model
    private func selectLiteral(clauseReference: ClauseReference,
                               selectable: (term_t) -> Bool = { _ in true }, // by default all literals are selectable
                               model: Yices.Model) -> LiteralIndex? {
        let (c, literals, shuffled) = yicesTuples[clauseReference]

        // find a selectable literal term that holds in the model
        guard let t = shuffled.first(where: {
            selectable($0) // the literal is selecteable
                && model.implies(formula: $0) // and holds in the model
        }) else {
            Syslog.error {
                "None of \(shuffled) in \(c) holds in model. \(literals) \(clause(byReference: clauseReference))"
            }
            return nil
        }
        // get the index of the literal term thats holds in the model
        guard let idx = literals.index(of: t) else {
            Syslog.error { "Literal \(t) was not found in \(literals). \(shuffled)" }
            return nil
        }

        return idx
    }

    /// check if a literal still holds
    private func validate(literalReference: LiteralReference,
                          model: Yices.Model) -> (term_t, Bool) {
        let t = yicesLiteral(byReference: literalReference)
        return (t, model.implies(formula: t))
    }

    /// append and register an allready _normalized_ and _encoded_ clause to collectction
    /// and return the clause reference
    private func append(clause: N, tuple: Yices.Tuple) -> ClauseReference {
        assert(clauses.count == yicesTuples.count)

        let (yicesClause, _, _) = tuple

        let clauseReference = clauses.count

        clauses.append(clause)
        yicesTuples.append(tuple)

        // add or update mapping from yices clause to (tptp) clause referneces
        if clauseReferences[yicesClause]?.insert(clauseReference) == nil {
            clauseReferences[yicesClause] = Set(arrayLiteral: clauseReference)
        }

        return clauseReference
    }

    /// insert the normalized copy of the clause if no variant is allready there
    func insert(clause: N) -> (inserted: Bool, referenceAfterInsert: ClauseReference) {

        let newClause = clause.normalized(prefix: "V")
        let newTriple = Yices.clause(newClause)

        // find first variant of given clause

        if let clauseReference = clauseReferences[newTriple.clause]?.first(where: {
            newClause == clauses[$0]
        }) {
            ignored += 1
            return (false, clauseReference)
        }

        // no variant of given clause was found
        return (true, append(clause: newClause, tuple: newTriple))
    }

    func clashingLiterals(literalReference: LiteralReference) -> Set<LiteralReference>? {
        guard let negatedLiteral = literal(byReference: literalReference).negated else {
            return nil
        }

        let paths = negatedLiteral.leafPaths

        return literalReferences.unifiables(paths: paths, wildcard: wildcardsymbol)
    }

    /// get clause and literal by literal reference
    private func clauseAndLiteral(literalReference: LiteralReference) -> (Clause, Literal) {
        let (clauseReference, literalIndex) = literalReference.values

        let clause = self.clause(byReference: clauseReference)
        return (clause, clause.nodes![literalIndex])
    }

    func processPending() {
        for (clauseReference, literalIndex) in pendingLiterals {
            let literalReference = Pair(clauseReference, literalIndex)
            for clause in derivations(literalReference: literalReference) {
                _ = insert(clause: clause)
                /*
                 if a {
                 print(b, clause)
                 } */
            }
            activate(literalReference: literalReference)
        }
    }

    func derivations(literalReference: LiteralReference) -> Array<Clause> {
        let (clauseReference, literalIndex) = literalReference.values

        // get clause and append clause index to variable names
        // e.g. p(x)|~q(y) -> p(x_i)|~q(y_i)
        let clause = self.clause(byReference: clauseReference).appending(suffix: clauseReference)

        // negate literal, e.g. p(x_i) -> ~p(x_i) or ~q(y_i) -> q(y_i)
        let negatedLiteral = clause.nodes![literalIndex].negated!

        let paths = negatedLiteral.leafPaths

        var array = Array<Clause>()

        guard let clashingLitaralReferences =
            literalReferences.unifiables(paths: paths, wildcard: self.wildcardsymbol) else {
            return array
        }

        for otherLiteralReference in clashingLitaralReferences {

            let (otherClause, otherLiteral) =
                clauseAndLiteral(literalReference: otherLiteralReference)

            let (inserted, _) = literalPairs.insert(Set([literalReference, otherLiteralReference]))

            assert(inserted, "\(literalReference), \(otherLiteralReference) allready drawn")

            if let mgu = negatedLiteral =?= otherLiteral {
                array.append(clause * mgu)
                array.append(otherClause * mgu)
            }
        }
        return array
    }

    func insure(clauseReference: ClauseReference, context: Yices.Context) -> Bool {
        let (yicesClause, _, _) = yicesTuples[clauseReference]

        guard context.insure(clause: yicesClause), let model = Yices.Model(context: context) else {
            Syslog.info {
                "[\(clauseReference)] \(yicesClause) is not satisfiable."
            }
            return false // not satisfiable
        }
        // context is satisfiable and a model was constructed

        // select literal with model
        pendingLiterals[clauseReference] = selectLiteral(
            clauseReference: clauseReference, model: model)

        for (clauseReference, literalIndex) in activeLiterals {
            let literalReference = LiteralReference(clauseReference, literalIndex)

            let (term, holds) = validate(
                literalReference: literalReference,
                model: model
            )

            if holds { continue }

            deactivate(literalReference: literalReference)

            pendingLiterals[clauseReference] = selectLiteral(
                clauseReference: clauseReference,
                selectable: { $0 != term }, // ignore previously checked yices literal
                model: model)
        }

        return true
    }
}
