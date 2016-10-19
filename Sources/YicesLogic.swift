import CYices

final class YicesExpr : LogicExpr {
  fileprivate var expr: term_t

  init(_ e: term_t) {
    self.expr = e
  }

  func not() -> YicesExpr {
    return YicesExpr(yices_not(expr))
  }

  func and(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_and2(self.expr, t.expr))
  }

  func or(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_or2(self.expr, t.expr))
  }

  func implies(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_implies(self.expr, t.expr))
  }

  func iff(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_iff(self.expr, t.expr))
  }

  func xor(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_xor2(self.expr, t.expr))
  }

  func ite(_ t: YicesExpr, _ f: YicesExpr) -> YicesExpr {
      return YicesExpr(yices_ite(self.expr, t.expr, f.expr))
  }

  // arithmetic operators
  func eq(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_eq(self.expr, t.expr))
  }

  func neq(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_neq(self.expr, t.expr))
  }

  func gt(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_arith_gt_atom(self.expr, t.expr))
  }

  func ge(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_arith_geq_atom(self.expr, t.expr))
  }

  func add(_ t: YicesExpr) -> YicesExpr {
    return YicesExpr(yices_add(self.expr, t.expr))
  }
  
  
	// term deconstruction
  /// Get children of a yices term.
  var children : [YicesExpr] {
    return (0..<yices_term_num_children(self.expr)).map {
      YicesExpr(yices_term_child(self.expr, $0))
    }
  }
}

final class YicesModel : LogicModel {
  typealias Expr = YicesExpr

  let context : YicesContext
  private var model: OpaquePointer

  init?(context: YicesContext) {
    guard let m = yices_get_model(context.context, 1) else {
      return nil
    }
    model = m
    self.context = context
  }

  deinit {
    yices_free_model(model)
  }
    // evaluation
  /// Evaluate a boolean term `t`
  func evalBool(_ term: Expr) -> Bool? {
    assert (context.bool_type == yices_type_of_term(term.expr))

		var p : Int32 = 0
    guard yices_get_bool_value(model, term.expr, &p) == 0 else {
      yices_print_error(stdout)
      return nil
    }
    return (p != 0)
  }

  /// Evaluate a term `t` of integer type
  func evalInt(_ term: Expr) -> Int? {
    assert (context.int_type == yices_type_of_term(term.expr))

		var p : Int32 = -1
    guard yices_get_int32_value(model, term.expr, &p) == 0  else {
      yices_print_error(stdout)
      return 0
    }
    return Int(p)
  }

  func implies(formula: Expr) -> Bool {
    let tau = yices_type_of_term(formula.expr)

<<<<<<< HEAD
    Syslog.error(condition: yices_type_is_bool(tau)==0) {
=======
    Syslog.error(condition: { yices_type_is_bool(tau)==0 }) {
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
      _ in
      let s = String(term: formula.expr) ?? "\(formula) n/a"
      let t = String(tau: tau) ?? "\(tau) n/a"

      return "Formula '\(s)' is not Boolean, but '\(t)'"
    }
    return yices_formula_true_in_model(model, formula.expr) > 0
  }

  func selectIndex<C: Collection>(literals: C) -> Int?
  where C.Iterator.Element == Expr {
    for (index, literal) in literals.enumerated() {
      if self.implies(formula: literal) {
        return index
      }
    }
    return nil
  }
}

final class YicesContext : LogicContext {
  typealias ExprType = type_t
  typealias Model = YicesModel
  typealias Expr = Model.Expr

  fileprivate var context : OpaquePointer
	
  // types
  let bool_type = yices_bool_type()
  let int_type = yices_int_type()
  let free_type = YicesContext.namedType("𝛕")

	// special constants
	var 🚧 : Expr = YicesContext.typedSymbol("⊥", YicesContext.namedType("𝛕"))

  init() {
    context = yices_new_context(nil)
  }

	deinit {
	  yices_free_context(context)
	}

	static var versionString: String {
		return String(validatingUTF8:yices_version) ?? "n/a"
	}

  // create terms
  var mkTop = YicesExpr(yices_true())
  var mkBot = YicesExpr(yices_false())

  func mkOr(_ ts: [Expr]) -> Expr {
    var ts_copy = ts.map{ $0.expr }
    return YicesExpr(yices_or(UInt32(ts.count), &ts_copy))
  }

  func mkAnd(_ ts: [Expr]) -> Expr {
    var ts_copy = ts.map{ $0.expr }
    return YicesExpr(yices_and(UInt32(ts.count), &ts_copy))
  }
  
  func freshVar(_ name: String, _ type: term_t) -> Expr  {
    let t = yices_new_uninterpreted_term(type)
    let code = yices_set_term_name(t, name)
    // FIXME: rather throw exception
    guard (code >= 0) else { yices_print_error(stdout); return mkBot }
    return YicesExpr(t)
  }

  func mkBoolVar(_ name: String) -> Expr {
    return freshVar(name, bool_type)
  }

  func mkIntVar(_ name: String) -> Expr {
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

  private static func typedSymbol(_ symbol: String, _ type: ExprType) -> Expr {
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
    return Expr(c)
  }

  /// Get or create a global constant `symbol` of type `term_tau`
  func constant(_ symbol: String, _ type: ExprType) -> Expr {
    return YicesContext.typedSymbol(symbol, type)
  }

  /// Create a homogenic domain tuple
  func domain(_ count: Int, _ type: ExprType) -> [ExprType] {
    return [ExprType](repeating: type, count: count)
  }

  /// Get or create a function symbol of type domain -> range
  func function(_ symbol: String, _ domain: [ExprType], _ range: ExprType) -> Expr {
    let type_f = yices_function_type(UInt32(domain.count), domain, range)
    return YicesContext.typedSymbol(symbol, type_f)
  }

  /// Create application of uninterpreted function or predicate named `symbol`
  /// with arguments `args` of implicit global type `free_type`
  /// and explicit return type `type`
  func app(_ symbol: String, _ args: [Expr], _ range: ExprType) -> Expr {
    guard args.count > 0 else { return constant(symbol, range) }

    let f = function(symbol, domain(args.count, free_type), range)
    let nargs = UInt32(args.count)
    return YicesExpr(yices_application(f.expr, nargs, args.map{ $0.expr }))
  }

  func mkNum(_ n: Int) -> Expr {
    return MemoryLayout<Int>.size == 4 ? YicesExpr(yices_int32(Int32(n)))
                                       : YicesExpr(yices_int64(Int64(n)))
  }

  // assertion and checking
  func ensure(_ formula: Expr) {
		yices_assert_formula(context, formula.expr)
	}

  func ensureCheck(formula: Expr) -> Bool {
		ensure(formula)
		return isSatisfiable
	}

	var isSatisfiable: Bool {
		switch yices_check_context(context, nil) {
			case STATUS_SAT:
				return true
			case STATUS_UNSAT:
				return false
			default:
				print("-------------------------------------------------------")
				assert(false)
				return true
		}
	}

  var model : Model? {
    guard isSatisfiable else { return nil }
    return Model(context: self)
  }
}
