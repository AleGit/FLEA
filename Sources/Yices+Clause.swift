//  Copyright © 2016 Alexander Maringele. All rights reserved.

import CYices

import Foundation

extension Yices {
  typealias Tuple = (
    clause: term_t,
    literals: [term_t],
    shuffled: [term_t]
  )

  /// Return a yices clause and yices literals from a node clause.
  /// The children of `yicesClause` may be different from `yicesLiterals`
  static func clause<N: Node>(_ clause:N) -> Tuple
  where N:SymbolStringTyped {

    let (_, type) = clause.symbolStringType

    switch type {
      case .disjunction:
        guard let literals = clause.nodes, literals.count > 0 else {
          Syslog.error(condition: { clause.nodes == nil}) { "clause.nodes == nil"}
          Syslog.info(condition: { clause.nodes != nil}) { "emtpy clause" }
          return (Yices.bot, [Yices.bot], [Yices.bot])
        }

        return Yices.clause(literals)

      // unit clause
      case .predicate, .negation, .equation, .inequation:
        Syslog.warning { "'\(clause)' was not a clause, but a literal." }
        let yicesLiteral = literal(clause)
          return (yicesLiteral, [yicesLiteral], [yicesLiteral])

          // not a clause at all
      default:
            Syslog.error { "'\(clause)' is of type \(type)" }
            assert(false, "\(#function)(\(clause)) Argument is of type \(type)")
            return (Yices.bot, [Yices.bot], [Yices.bot])
    }


  }

        /// Return a yices clause and yices literals from an array of node literals.
        /// The children of `yicesClause` are often different from `yicesLiterals`.
        /// `yicesLiterals` are a mapping from `literals` to yices terms, while
        /// `yicesClause` is just equivalent to the conjunction of the `yicesLiterals`.
        /// * `true ≡ [ ⊥ = ⊥, ... ]`
        /// * `true ≡ [ p, ~p ]`
        /// * `true ≡ [ ⊥ = ⊥, ⊥ ~= ⊥ ]`
        /// * `p ≡ [ p, p ]`
        /// * `p ≡ [ ⊥ ~= ⊥, p ]`
        /// * `[p,q,q,q,q] ≡ [ p, q, ⊥ ~= ⊥, p,q ]`
  static func clause<N: Node>(_ literals:[N]) -> Tuple
  where N:SymbolStringTyped {
          /* (yicesClause: type_t, yicesLiterals:[type_t], alignedYicesLiterals:[type_t]) */

          let yicesLiterals = literals.map { self.literal($0) }
          var copy = yicesLiterals

          // `yices_or` might change the order and content of the array

          let yicesClause = yices_or( UInt32(copy.count), &copy)

          Syslog.info(condition: { yicesLiterals != copy}) {
            "yices literals reorderd"
            }
          Syslog.info(condition: { yicesLiterals.contains(yicesClause)}) {
            "yices literals contain clause"
            }

          return (
            yicesClause,
            yicesLiterals,
            copy
          )
        }

        /// Build boolean term from literal, i.e.
        /// - a negation
        /// - an equation
        /// - an inequation
        /// - a predicatate term or a proposition constant
  private static func literal<N: Node>(_ literal:N) -> term_t
  where N:SymbolStringTyped {

    guard let nodes = literal.nodes
    else {
      return yices_false()
    }

    // By default a symbol is a predicate symbol
    // if it is not predefined or registered.
    let (literalSymbolString, type) = literal.symbolStringType

    switch type {
      case .negation:
        assert(nodes.count == 1, "A negation must have exactly one child.")
        // no need to register negations
        return yices_not( Yices.literal(nodes.first! ))

      case .inequation:
        assert(nodes.count == 2, "An inequation must have exactly two children.")
        // inequations must be registered to check if equality axioms are needed

        let args = nodes.map { Yices.term($0) }
        return yices_neq(args.first!, args.last!)

      case .equation:
        assert(nodes.count == 2, "An equation must have exactly two children.")
        // equations must be registered to check if equality axioms are needed
        let args = nodes.map { Yices.term($0) }
        return yices_eq(args.first!, args.last!)

      case .predicate:
        // predicates must be registered to derive congruence axioms

        // proposition or predicate term (an application of Boolean type)
        return Yices.application(literalSymbolString, nodes:nodes, term_tau: Yices.bool_tau)

      default:
        assert(false, "'\(#function)(\(literal))' Argument must not be a \(type).")
        return yices_false()
    }
  }

                  /// Build uninterpreted function term from term.
  private static func term<N: Node>(_ term:N) -> term_t
  where N:SymbolStringTyped {
  // assert(term.isTerm,"'\(#function)(\(term))' Argument must be a term, but it is not.")

    let (termSymbolString, _) = term.symbolStringType

    guard let nodes = term.nodes else {
      return Yices.🚧 // substitute all variables with global constant '⊥'
    }

    // functions must be registered to derive congruence axioms
    // term.register(.function, category:.functor, notation:.prefix, arity:.fixed(nodes.count))

    // function or constant term (an application of uninterpreted type)
    return Yices.application(termSymbolString, nodes:nodes, term_tau:Yices.free_tau)
  }

  // swiftlint:disable variable_name (term_tau, 🚧)

  /// Build (constant) predicate or function.
  private static func application<N: Node>(_ symbolString:String,
  nodes:[N], term_tau: type_t) -> term_t
  where N:SymbolStringTyped {

    guard nodes.count > 0 else {
      return constant(symbolString, term_tau: term_tau)
    }

    return application(symbolString, args: nodes.map { Yices.term($0) }, term_tau: term_tau)
  }

  /// Uninterpreted global constant (i.e. variable) of uninterpreted type.
  private static var 🚧 : term_t {
    return Yices.constant("⊥", term_tau: free_tau)
  }
  // swiftlint:enable variable_name
}
