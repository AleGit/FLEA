//
//  Yices+Node.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import CYices

import Foundation

extension Yices {
  typealias Tuple = (
    clause: term_t,
    literals: [term_t]?
  )

  /// Return a yices clause and yices literals from a node clause.
  /// The children of `yicesClause` are often different from `yicesLiterals`.
  static func clause<N:Node where N:Typed>(_ clause:N) -> Tuple {
    /* (yicesClause: type_t, yicesLiterals:[type_t], alignedYicesLiterals:[type_t]) */
    // assert(clause.isClause,"'\(#function)(\(clause))' Argument must be a clause, but it is not.")

    let (_,type) = clause.symbolStringType

    switch type {
      case .disjunction:
        guard let literals = clause.nodes, literals.count > 0 else {
          return (Yices.bot, nil)
        }

        return Yices.clause(literals)

      // unit clause
      case .predicate, .negation, .equation, .inequation:
        Syslog.warning { "'\(clause)' was not a clause, but a literal." }
        let yicesLiteral = literal(clause)
          return (yicesLiteral,[yicesLiteral])

          // not a clause at all
      default:
            Syslog.error { "'\(clause)' is of type \(type)" }
            assert(false, "\(#function)(\(clause)) Argument is of type \(type)")
            return (Yices.bot, nil)
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
  static func clause<N:Node where N:Typed>(_ literals:[N]) -> Tuple {
          /* (yicesClause: type_t, yicesLiterals:[type_t], alignedYicesLiterals:[type_t]) */

          let literals = literals.map { self.literal($0) }
          var copy = literals

          // `yices_or` might change the order and content of the array

          let yicesClause = yices_or( UInt32(copy.count), &copy)

          return (
            yicesClause,
            literals
          )
        }

        /// Build boolean term from literal, i.e.
        /// - a negation
        /// - an equation
        /// - an inequation
        /// - a predicatate term or a proposition constant
  static func literal<N:Node where N:Typed>(_ literal:N) -> term_t {
    // assert(literal.isLiteral,"'\(#function)(\(literal))' Argument must be a literal, but it is not.")

    guard let nodes = literal.nodes
    else {
      return yices_false()
    }

    // By default a symbol is a predicate symbol
    // if it is not predefined or registered.
    let (literalSymbolString,type) = literal.symbolStringType

    switch type {
      case .negation:
        assert(nodes.count == 1, "A negation must have exactly one child.")
        // no need to register negations
        // literal.register(.negation, category: .Functor, notation:.Prefix, arity:.Fixed(1))
        return yices_not( Yices.literal(nodes.first! ))

      case .inequation:
        assert(nodes.count == 2, "An inequation must have exactly two children.")
        // inequations must be registered to check if equality axioms are needed
        //literal.register(.inequation, category: .equational, notation:.infix, arity:.fixed(2))

        let args = nodes.map { Yices.term($0) }
        return yices_neq(args.first!, args.last!)

      case .equation:
        assert(nodes.count == 2, "An equation must have exactly two children.")
        // equations must be registered to check if equality axioms are needed
        // literal.register(.equation, category: .equational, notation:.infix, arity:.fixed(2))
        let args = nodes.map { Yices.term($0) }
        return yices_eq(args.first!, args.last!)

      case .predicate:
        // predicates must be registered to derive congruence axioms
        // literal.register(.predicate, category:.functor, notation:.prefix, arity:.fixed(nodes.count))

        // proposition or predicate term (an application of Boolean type)
        return Yices.application(literalSymbolString, nodes:nodes, term_tau: Yices.bool_tau)

      default:
        assert(false, "'\(#function)(\(literal))' Argument must not be a \(type).")
        return yices_false()
    }
  }

                  /// Build uninterpreted function term from term.
  static func term<N:Node where N:Typed>(_ term:N) -> term_t {
  // assert(term.isTerm,"'\(#function)(\(term))' Argument must be a term, but it is not.")

    let (termSymbolString,_) = term.symbolStringType

    guard let nodes = term.nodes else {
      return Yices.🚧 // substitute all variables with global constant '⊥'
    }

    // functions must be registered to derive congruence axioms
    // term.register(.function, category:.functor, notation:.prefix, arity:.fixed(nodes.count))

    // function or constant term (an application of uninterpreted type)
    return Yices.application(termSymbolString, nodes:nodes, term_tau:Yices.free_tau)
  }

  /// Build (constant) predicate or function.
  static func application<N:Node where N:Typed>(_ symbolString:String, nodes:[N], term_tau:type_t) -> term_t {

    guard nodes.count > 0 else {
      return constant(symbolString, term_tau: term_tau)
    }

    return application(symbolString, args: nodes.map { Yices.term($0) }, term_tau: term_tau)
  }

                  /// Uninterpreted global constant (i.e. variable) of uninterpreted type.
  static var 🚧 : term_t {
    return Yices.constant("⊥", term_tau: free_tau)
  }
}
