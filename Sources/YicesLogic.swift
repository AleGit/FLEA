import CYices

class YicesLogic : Logic {
  typealias Term = term_t
  typealias TType = type_t
  typealias Model = OpaquePointer

  var ctx : OpaquePointer
	
  // types
  let bool_type = yices_bool_type()
  let int_type = yices_int_type()
  let free_type = YicesLogic.namedType("𝛕")
	// constants
	var 🚧 : Term = YicesLogic.typedSymbol("⊥", YicesLogic.namedType("𝛕"))

  init() {
    ctx = yices_new_context(nil)
  }

	deinit {
		yices_free_context(ctx)
	}

	static var versionString: String {
		return String(validatingUTF8:yices_version) ?? "n/a"
	}

  // logical operators
  var top = yices_true()
  var bot = yices_false()

  func not(_ t: Term) -> Term {
    return yices_not(t)
  }

  func and(_ s : Term, _ t: Term) -> Term {
    return yices_and2(s, t)
  }

  func and(_ ts: [Term]) -> Term {
    var ts_copy = ts
    return yices_and(UInt32(ts.count), &ts_copy)
  }

  func or(_ s: Term, _ t: Term) -> Term {
    return yices_or2(s, t)
  }

  func or(_ ts: [Term]) -> Term {
    var ts_copy = ts
    return yices_or(UInt32(ts.count), &ts_copy)
  }

  func implies(_ s: Term, _ t: Term) -> Term {
    return yices_implies(s, t)
  }

  func ite(_ c: Term, t: Term, f: Term) -> Term {
      return yices_ite(c, t, f)
  }

  // arithmetic operators
  func eq(_ s: Term, _ t: Term) -> Term {
    return yices_eq(s, t)
  }

  func neq(_ s : Term, _ t: Term) -> Term {
    return yices_neq(s, t)
  }

  func gt(_ s: Term, _ t: Term) -> Term {
    return yices_arith_gt_atom(s, t)
  }

  func ge(_ s: Term, _ t: Term) -> Term {
    return yices_arith_geq_atom(s, t)
  }

  func add(_ s: Term, _ t: Term) -> Term {
    return yices_add(s, t)
  }
  
  // create terms
  func freshVar(_ name: String, _ type: term_t) -> Term  {
    let t = yices_new_uninterpreted_term(type)
    let code = yices_set_term_name(t, name)
    // FIXME: rather throw exception
    guard (code >= 0) else { yices_print_error(stdout); return bot }
    return t
  }

  func freshBoolVar(_ name: String) -> Term {
    return freshVar(name, bool_type)
  }

  func freshIntVar(_ name: String) -> Term {
    return freshVar(name, int_type)
  }

  private static func namedType(_ name: String) -> type_t {
    assert(!name.isEmpty, "a type name must not be empty")
    var tau = yices_get_type_by_name(name)
    if tau == NULL_TYPE {
      tau = yices_new_uninterpreted_type()
      yices_set_type_name(tau, name)
    }
    return tau
  }

  private static func typedSymbol(_ symbol: String, _ type: TType) -> Term {
    assert(!symbol.isEmpty, "a symbol name must not be empty")

    var c = yices_get_term_by_name(symbol)
    if c == NULL_TERM {
      c = yices_new_uninterpreted_term(type)
      yices_set_term_name(c, symbol)
    } else {
      let ctype = yices_type_of_term(c)
      assert (type == ctype,
        "\(String(tau:type)) != \(String(tau: ctype)) \(String(term:c)) for '\(symbol)'")
    }
    return c
  }

  /// Get or create a global constant `symbol` of type `term_tau`
  func getConst(_ symbol: String, _ type: TType) -> Term {
    return YicesLogic.typedSymbol(symbol, type)
  }

  /// Create a homogenic domain tuple
  func getDomain(_ count: Int, _ type: TType) -> [TType] {
    return [TType](repeating: type, count: count)
  }

  /// Get or create a function symbol of type domain -> range
  func getFun(_ symbol: String, _ domain: [TType], _ range: TType) -> Term {
    let type_f = yices_function_type(UInt32(domain.count), domain, range)
    return YicesLogic.typedSymbol(symbol, type_f)
  }

  /// Create application of uninterpreted function or predicate named `symbol`
  /// with arguments `args` of implicit global type `free_type`
  /// and explicit return type `type`
  func getApp(_ symbol: String, _ args: [Term], _ range: TType) -> Term {
    guard args.count > 0 else { return getConst(symbol, range) }

    let f = getFun(symbol, getDomain(args.count, free_type), range)
    return yices_application(f, UInt32(args.count), args)
  }

	// term deconstruction
  /// Get children of a yices term.
  func children(_ term: Term) -> [Term] {
    return (0..<yices_term_num_children(term)).map { yices_term_child(term, $0) }
  }

  func subterms(_ term: Term) -> Set<Term> {
    var terms = Set(children(term).flatMap { subterms($0) })
    terms.insert(term)
    return terms
  }

  // evaluation
  /// Evaluate a boolean term `t` in `model`
  func evalBool(_ model: Model, _ t: Term) -> Bool {
    assert (bool_type == yices_type_of_term(t))

		var p : Int32 = 0
    let success = yices_get_bool_value(model, t, &p)
    // FIXME: rather throw exception
    guard success == 0  else {
      yices_print_error(stdout)
      return false
    }
    return  (p != 0)
  }

  /// Evaluate a term `t` of integer type in `model`
  func evalInt(_ model: Model, _ t: Term) -> Int {
    assert (int_type == yices_type_of_term(t))

		var p : Int32 = -1
    let success = yices_get_int32_value(model, t, &p)
    // FIXME: rather throw exception
    guard success == 0  else {
      yices_print_error(stdout)
      return 0
    }
    return Int(p)
  }
}
