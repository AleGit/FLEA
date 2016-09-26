//
//  Yices.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.08.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import CYices

// MARK: types and terms

extension Yices {
    // swiftlint:disable variable_name

    /// Boolean type for predicates and connectives (built-in)
    static var bool_tau = yices_bool_type()
    /// Integer type for linear integer arithmetic (build-in)
    static var int_tau = yices_int_type()

    /// Uninterpreted global type - the return type of uninterpreted terms
    /// (functions or constants).
    static var free_tau: type_t {
        return namedType("𝛕")
    }
    // swiftlint:enable  variable_name

    /// Get or create (uninterpreted) type `name`.
    static func namedType(_ name: String) -> type_t {
        assert(!name.isEmpty, "a type name must not be empty")
        var tau = yices_get_type_by_name(name)
        if tau == NULL_TYPE {
            tau = yices_new_uninterpreted_type()
            yices_set_type_name(tau, name)
        }
        return tau
    }



    /// Get or create an uninterpreted global `symbol` of type `term_tau`.
    static func typedSymbol(_ symbol: String, term_tau: type_t) -> term_t {
        assert(!symbol.isEmpty, "a typed symbol must not be empty")

        var c = yices_get_term_by_name(symbol)
        if c == NULL_TERM {
            c = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(c, symbol)
        } else {
            assert (term_tau == yices_type_of_term(c),
            // swiftlint:disable line_length
            "\(String(tau:term_tau), term_tau) != \(String(tau: yices_type_of_term(c)), yices_type_of_term(c)) \(String(term:c)) for '\(symbol)'")
            // swiftlint:enable line_length

        }
        return c
    }

    /// Get or create a global constant `symbol` of type `term_tau`
    static func constant(_ symbol: String, term_tau: type_t) -> term_t {
        return typedSymbol(symbol, term_tau: term_tau)
    }

    /// Create a homogenic domain tuple
    static func domain(_ count: Int, tau: type_t) -> [type_t] {
        return [type_t](repeating: tau, count: count)
    }

    /// Get or create a function symbol of type domain -> range
    static func function(_ symbol: String, domain: [type_t], range: type_t) -> term_t {

        let f_tau = yices_function_type(UInt32(domain.count), domain, range)

        return typedSymbol(symbol, term_tau: f_tau)
    }

    /// Create uninterpreted global (predicate) function `symbol` application
    /// with uninterpreted arguments `args` of implicit global type `free_type`
    /// and explicit return type `term_tau`:
    /// * `free_tau` - the symbol is a constant/function symbol
    /// * `bool_tau` - the symbol is a proposition/predicate symbol
    static func application(_ symbol: String, args: [term_t], term_tau: type_t) -> term_t {

        guard args.count > 0 else { return constant(symbol, term_tau: term_tau) }

        let f = function(symbol, domain:domain(args.count, tau:Yices.free_tau), range: term_tau)
        return yices_application(f, UInt32(args.count), args)
    }

    /// Get yices children of a yices term.
    static func children(_ term: term_t) -> [term_t] {
        return (0..<yices_term_num_children(term)).map { yices_term_child(term, $0) }
    }

    static func subterms(_ term: term_t) -> Set<term_t> {
        var terms = Set(children(term).flatMap { subterms($0) })
        terms.insert(term)
        return terms
    }
}

/// MARK: - Boolean terms
extension Yices {
    static var top: term_t {
        return yices_true()
    }

    static var bot: term_t {
        return yices_false()
    }

    static func not(_ t: term_t) -> term_t {
        return yices_not(t)
    }

    static func and(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_and2(t1, t2)
    }

    static func and(_ t1: term_t, _ t2: term_t, _ t3: term_t) -> term_t {
        return yices_and3(t1, t2, t3)
    }

    static func and(_ ts: [term_t]) -> term_t {
        var copy = ts
        // argument array must be mutable, because it will be reordered and optimized
        return yices_and(UInt32(ts.count), &copy)
    }

    static func or(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_or2(t1, t2)
    }

    static func or(_ t1: term_t, _ t2: term_t, _ t3: term_t) -> term_t {
        return yices_or3(t1, t2, t3)
    }

    static func or(_ ts: [term_t]) -> term_t {
        var copy = ts
        // argument array must be mutable, because it will be reordered and optimized
        return yices_or(UInt32(ts.count), &copy)
    }

    static func implies(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_implies(t1, t2)
    }

    static func ite(_ c: term_t, t: term_t, f: term_t) -> term_t {
        return yices_ite(c, t, f)
    }

    static func gt(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_arith_gt_atom(t1, t2)
    }

    static func ge(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_arith_geq_atom(t1, t2)
    }

    static func eq(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_eq(t1, t2)
    }
}

// MARK: - arithmetic terms
extension Yices {
    static func add(_ t1: term_t, _ t2: term_t) -> term_t {
        return yices_add(t1, t2)
    }

    static func sum(_ ts: [term_t]) -> term_t {
        var copy = ts
        return yices_sum(UInt32(copy.count), &copy)
    }

    static var zero: term_t {
        return yices_int32(0)
    }

    static var one: term_t {
        return yices_int32(1)
    }
}

// MARK: - eval

extension Yices {

    static func getValue(_ t: term_t, mdl: OpaquePointer) -> Bool? {
        var val: Int32 = 0
        if Yices.check (code:yices_get_int32_value(mdl, t, &val), label:"\(#function) : Bool") {
            return val == 0 ? false : true
        } else {
            return nil
        }
    }

    static func getValue(_ t: term_t, mdl: OpaquePointer) -> Int32? {
        var val: Int32 = 0
        if Yices.check (code:yices_get_int32_value(mdl, t, &val), label:"\(#function) : Int32") {
            return val
        } else {
            return nil
        }
    }
}

extension Yices {
    static func info(tau: type_t) -> (name: String, infos: [String])? {
        guard let name = String(tau:tau) else { return nil }

        var infos = [String]()

        if yices_type_is_bool(tau)==1 { infos.append("is_bool") }
        if yices_type_is_int(tau)==1 { infos.append("is_int") }
        if yices_type_is_real(tau)==1 { infos.append("is_real") }
        if yices_type_is_arithmetic(tau)==1 { infos.append("is_arithmetic") }
        if yices_type_is_bitvector(tau)==1 { infos.append("is_bitvector") }
        if yices_type_is_tuple(tau)==1 { infos.append("is_tuple") }
        if yices_type_is_function(tau)==1 { infos.append("is_function") }
        if yices_type_is_scalar(tau)==1 { infos.append("is_scalar") }
        if yices_type_is_uninterpreted(tau)==1 { infos.append("is_uninterpreted") }

        return (name, infos)

    }

    typealias TermInfo = (term_t, term: String,
    type: (name: String, infos: [String]), children: [term_t])

    static func info(term: term_t) -> TermInfo? {
        let tau = yices_type_of_term(term)
        guard let name = String(term:term), let type = Yices.info(tau:tau)
        else { return nil }

        return (term, name, type, Yices.children(term))

    }

    static func infos(term: term_t) -> [TermInfo] {
        // return Yices.subterms(term).map { Yices.info(term:$0) }.filter { $0 != nil }.map { $0! }

        return [Yices.info(term:term)!] + Yices.children(term).flatMap { Yices.infos(term:$0) }
    }
}
