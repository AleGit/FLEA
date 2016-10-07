//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

extension Logic {
  typealias Tuple = (
    clause: Term,
    literals: [Term],
    shuffled: [Term]
  )

  /// Return an SMT clause and SMT literals from a node clause.
  /// The children of `smtClause` may be different from `smtLiterals`
  func clause<N: Node>(_ clause:N) -> Tuple
  where N:SymbolStringTyped {

    let (_, type) = clause.symbolStringType

    switch type {
      case .disjunction:
        guard let literals = clause.nodes, literals.count > 0 else {
          Syslog.error(condition: { clause.nodes == nil}) { "clause.nodes == nil"}
          Syslog.info(condition: { clause.nodes != nil}) { "emtpy clause" }
          return (bot, [bot], [bot])
        }

        return self.clause(literals)

      // unit clause
      case .predicate, .negation, .equation, .inequation:
        Syslog.warning { "'\(clause)' was not a clause, but a literal." }
        let smtLiteral = literal(clause)
        return (smtLiteral, [smtLiteral], [smtLiteral])

      // not a clause at all
      default:
        Syslog.error { "'\(clause)' is of type \(type)" }
        assert(false, "\(#function)(\(clause)) Argument is of type \(type)")
        return (bot, [bot], [bot])
    }
  }

	/// Return an SMT clause and SMT literals from an array of node literals.
	/// The children of `smtClause` are often different from `smtLiterals`.
	/// `smtLiterals` are a mapping from `literals` to SMT terms, while
	/// `smtClause` is just equivalent to the conjunction of the `smtLiterals`.
	/// * `true ≡ [ ⊥ = ⊥, ... ]`
	/// * `true ≡ [ p, ~p ]`
	/// * `true ≡ [ ⊥ = ⊥, ⊥ ~= ⊥ ]`
	/// * `p ≡ [ p, p ]`
	/// * `p ≡ [ ⊥ ~= ⊥, p ]`
	/// * `[p,q,q,q,q] ≡ [ p, q, ⊥ ~= ⊥, p,q ]`
  func clause<N: Node>(_ literals:[N]) -> Tuple
  where N:SymbolStringTyped {
		/* (smtClause: type_t, smtLiterals:[type_t], alignedYicesLiterals:[type_t]) */

		let smtLiterals = literals.map { self.literal($0) }

		// Logic.or might change the order and content of the array
		let smtClause = or(smtLiterals)

		//Syslog.info(condition: { smtLiterals != children(smtClause)}) {
		//	"Logic.or reordered literals"
		//}
		//Syslog.info(condition: { smtLiterals.contains(smtClause)}) {
		//	"SMT literals contain clause"
		//}

		return (smtClause, smtLiterals, children(smtClause))
	}

	/// Build boolean term from literal, i.e.
	/// - a negation
	/// - an equation
	/// - an inequation
	/// - a predicatate term or a proposition constant
  private func literal<N: Node>(_ literal:N) -> Term
  where N:SymbolStringTyped {

    guard let nodes = literal.nodes else { return bot }

    // By default a symbol is a predicate symbol
    // if it is not predefined or registered.
    let (literalSymbolString, type) = literal.symbolStringType

    switch type {
      case .negation:
        assert(nodes.count == 1, "A negation must have exactly one child.")
        // no need to register negations
        return not( self.literal(nodes.first! ))

      case .inequation:
        assert(nodes.count == 2, "An inequation must have exactly two children.")
        // inequations must be registered to check if equality axioms are needed

        let args = nodes.map { term($0) }
        return neq(args.first!, args.last!)

      case .equation:
        assert(nodes.count == 2, "An equation must have exactly two children.")
        // equations must be registered to check if equality axioms are needed
        let args = nodes.map { term($0) }
        return eq(args.first!, args.last!)

      case .predicate:
        // predicates must be registered to derive congruence axioms

        // proposition or predicate term (an application of Boolean type)
        return getApp(literalSymbolString, nodes.map(term), bool_type)

      default:
        assert(false, "'\(#function)(\(literal))' Argument must not be a \(type).")
        return bot
    }
  }

  /// Build uninterpreted function term from term.
  private func term<N: Node>(_ term:N) -> Term
  where N:SymbolStringTyped {
  // assert(term.isTerm,"'\(#function)(\(term))' Argument must be a term, but it is not.")

    let (termSymbolString, _) = term.symbolStringType

    guard let nodes = term.nodes else {
      return 🚧 // substitute all variables with global constant '⊥'
    }

    // functions must be registered to derive congruence axioms
    // term.register(.function, category:.functor, notation:.prefix, arity:.fixed(nodes.count))

    // function or constant term (an application of uninterpreted type)
    return getApp(termSymbolString, nodes.map(self.term), free_type)
  }
}
