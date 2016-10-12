import CZ3Api


public final class Z3Expr : LogicExpr {
  fileprivate var expr: Z3_ast
  fileprivate var ctx: Z3_context? = nil

  init(_ c: Z3_context, expr: Z3_ast) {
    self.expr = expr
    self.ctx = c
    Z3_inc_ref(self.ctx!, self.expr)
  }

  deinit {
    if (self.ctx != nil) {
      Z3_dec_ref(self.ctx!, self.expr)
    }
  }

  func clear() {
    Z3_dec_ref(self.ctx!, self.expr)
    ctx = nil
  }

  func not() -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_not(ctx!, expr))
  }

  func and(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_and(ctx!, UInt32(2), [self.expr, t.expr]))
  }

  func or(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_or(ctx!, 2, [self.expr, t.expr]))
  }

  func implies(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_implies(ctx!, self.expr, t.expr))
  }

  func ite(_ t: Z3Expr, _ f: Z3Expr) -> Z3Expr {
      return Z3Expr(ctx!, expr: Z3_mk_ite(ctx!, self.expr, t.expr, f.expr))
  }

  // arithmetic operators
  func eq(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_eq(ctx!, self.expr, t.expr))
  }

  func neq(_ t: Z3Expr) -> Z3Expr {
    return !Z3Expr(ctx!, expr: Z3_mk_eq(ctx!, self.expr, t.expr))
  }

  func gt(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_gt(ctx!, self.expr, t.expr))
  }

  func ge(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_ge(ctx!, self.expr, t.expr))
  }

  fileprivate static func toZ3Array(_ ts: [Z3Expr]) -> 
                                    UnsafeMutablePointer<Z3_ast?> {
    let size = MemoryLayout<Z3_ast>.size * ts.count
    let tsp = UnsafeMutablePointer<Z3_ast?>.allocate(capacity: size)
    for i in (0..<ts.count) {
      tsp[i] = ts[i].expr
    }
    return tsp
  }

  func add(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx!, expr: Z3_mk_add(ctx!, 2, [self.expr, t.expr]))
  }
  
  
	// term deconstruction
  /// Get children of a Z3 term.
  var children : [Z3Expr] {
    guard (Z3_get_ast_kind(ctx!, self.expr) == Z3_APP_AST) else {
       return []
    }
    let app = Z3_to_app(ctx!, self.expr)
    let numargs = Z3_get_app_num_args(ctx!, app)
    return (0..<numargs).map {
      Z3Expr(ctx!, expr: Z3_get_app_arg(ctx!, app, $0))
    }
  }
}

public final class Z3Model : LogicModel {
  typealias Expr = Z3Expr

  fileprivate let ctx : Z3Context
  fileprivate var model: Z3_model

  init?(_ ctx: Z3Context, _ model: Z3_model) {
    self.model = model
    self.ctx = ctx
    Z3_model_inc_ref(ctx.ctx, model)
  }

  deinit {
    Z3_model_dec_ref(ctx.ctx, model)
  }

  // evaluation
  /// Evaluate a boolean term `t`
  func eval(_ term: Expr) -> Z3_ast? {
    let cap = MemoryLayout<Int>.size
    let p = UnsafeMutablePointer<Z3_ast?>.allocate(capacity: cap)
    p.initialize(to: nil)

    // set model completion to true
    guard Z3_model_eval(ctx.ctx, model, term.expr, Z3_TRUE,p) == Z3_TRUE  else {
      Syslog.error { "Z3 evaluation failed" }
      return nil
    }
    return p.pointee
  }

  /// Evaluate a boolean term `t`
  func evalBool(_ term: Expr) -> Bool? {
    assert (ctx.bool_type == Z3_get_sort(ctx.ctx, term.expr))
    guard let val = eval(term) else { return nil }
    return Z3_get_bool_value(ctx.ctx, val) == Z3_L_TRUE
  }

  /// Evaluate a term `t` of integer type
  func evalInt(_ term: Expr) -> Int? {
    assert (ctx.int_type == Z3_get_sort(ctx.ctx, term.expr))
    var num : Int32 = 0
    guard let val = eval(term) else { return nil }
    guard Z3_get_numeral_int(ctx.ctx, val, &num) == Z3_TRUE  else {
      Syslog.error { "Z3 numeral conversion failed" }
      return nil
    }
    return Int(num)
  }

  func implies(formula: Expr) -> Bool {
    let tau = Z3_get_sort(ctx.ctx, formula.expr)

    Syslog.error(condition: { ctx.bool_type != tau }) {
      _ in
      let s = String(expr: formula) ?? "\(formula) n/a"
      return "Formula '\(s)' is not Boolean"
    }
    guard let val = evalBool(formula) else { return false }
    return val
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


public extension String {
  /// Creates a String representation of a Z3 expression
  public init?(expr: Z3Expr) {
    guard let cstring = Z3_ast_to_string(expr.ctx!, expr.expr) else {
      Syslog.error { "could not create String from Z3 expression" }
      return nil
    }
    guard let string = String(validatingUTF8:cstring) else { return nil }
    self = string
  }

  /// Creates a String representation of a Z3 model
  public init?(model: Z3Model) {
    guard let cstring = Z3_model_to_string(model.ctx.ctx, model.model) else {
      Syslog.error { "could not create String from Z3 model" }
      return nil
    }
    guard let string = String(validatingUTF8:cstring) else { return nil }
    self = string
  }
}


final class Z3Context : LogicContext {
  typealias ExprType = Z3_sort
  typealias Model = Z3Model
  typealias Expr = Model.Expr

  fileprivate var ctx : Z3_context
  private var solver: Z3_solver? = nil
  private var optimize: Z3_optimize? = nil

  // types
  let bool_type : Z3_sort
  let int_type : Z3_sort
  var free_type : Z3_sort

	// special constants
	var 🚧 : Expr

  init(optimize: Bool) {
    ctx = Z3_mk_context(Z3_mk_config())
    if (optimize) {
      self.optimize = Z3_mk_optimize(self.ctx)
      Z3_inc_ref(self.ctx, self.optimize!)
    } else{
      solver = Z3_mk_solver(ctx)
      Z3_solver_inc_ref(ctx, solver!)
    }

    mkTop = Z3Expr(ctx, expr: Z3_mk_true(ctx))
    mkBot = Z3Expr(ctx, expr: Z3_mk_false(ctx))
    🚧 = mkBot // dummy

    bool_type = Z3_mk_bool_sort(ctx)
    int_type = Z3_mk_int_sort(ctx)
    free_type = bool_type // dummy

    free_type = namedType("𝛕")
	  🚧 = typedSymbol("⊥", free_type)
  }

  convenience init() {
    self.init(optimize: false)
  }

	deinit {
    // do cleanup manually, to avoid crash because of cyclic dependencies
    mkTop.clear()
    mkBot.clear()
    🚧.clear()

    if (self.optimize != nil) {
      Z3_dec_ref(self.ctx, self.optimize!)
    } else {
      Z3_solver_dec_ref(ctx, solver!)
    }
	  Z3_del_context(ctx)
	}

	static var versionString: String {
		var major = UInt32()
    var minor = UInt32()
    var build = UInt32()
    var revision = UInt32()

    Z3_get_version(&major, &minor, &build, &revision)
    return "\(major).\(minor).\(build).\(revision)"
	}

  var mkTop : Expr
  var mkBot : Expr

  func mkOr(_ ts: [Expr]) -> Expr {
    return Z3Expr(ctx, expr: Z3_mk_or(ctx, UInt32(ts.count),
                  Expr.toZ3Array(ts)))
  }

  func mkAnd(_ ts: [Expr]) -> Expr {
    return Z3Expr(ctx, expr: Z3_mk_and(ctx, UInt32(ts.count),
                  Expr.toZ3Array(ts)))
  }
  
  func freshVar(_ name: String, _ type: ExprType) -> Expr  {
    let v = Z3_mk_const(ctx, Z3_mk_string_symbol(ctx, name), type)
    guard v != nil else {
      Syslog.error { "Z3 fresh var failed" }
      return mkBot
    }
    return Z3Expr(ctx, expr: v!)
  }

  func mkBoolVar(_ name: String) -> Expr {
    return freshVar(name, bool_type)
  }

  func mkIntVar(_ name: String) -> Expr {
    return freshVar(name, int_type)
  }

  private func namedType(_ name: String) -> ExprType {
    assert(!name.isEmpty, "a type name must not be empty")
    // two types are considered the same if they have the same name
    return Z3_mk_uninterpreted_sort(ctx, Z3_mk_string_symbol(ctx, name))
  }

  private func typedSymbol(_ symbol: String, _ type: ExprType) -> Expr {
    assert(!symbol.isEmpty, "a symbol name must not be empty")
    let c = Z3_mk_const(ctx, Z3_mk_string_symbol(ctx, symbol), type)
    guard c != nil else {
      Syslog.error { "Z3 typedSymbol failed" }
      return mkBot
    }
    return Z3Expr(ctx, expr: c!)
  }

  /// Get or create a global constant `symbol` of type `term_tau`
  func constant(_ symbol: String, _ type: ExprType) -> Expr {
    return typedSymbol(symbol, type)
  }

  /// Create a homogenic domain tuple
  func domain(_ count: Int, _ type: ExprType) -> UnsafeMutablePointer<Z3_ast?> {
    let size = MemoryLayout<Z3_sort>.size * count
    let tsp = UnsafeMutablePointer<Z3_ast?>.allocate(capacity: size)
    for i in (0..<count) {
      tsp[i] = type
    }
    return tsp
  }

  /// Create application of uninterpreted function or predicate named `symbol`
  /// with arguments `args` of implicit global type `free_type`
  /// and explicit return type `type`
  func app(_ symbol: String, _ args: [Expr], _ range: ExprType) -> Expr {
    guard args.count > 0 else { return constant(symbol, range) }

    let nargs = UInt32(args.count)
    let dom = domain(args.count, free_type)
    let sym = Z3_mk_string_symbol(ctx, symbol)
    let decl = Z3_mk_func_decl(ctx, sym, nargs, dom, range)
    return Z3Expr(ctx, expr: Z3_mk_app(ctx, decl, nargs, args.map{ $0.expr }))
  }

  func mkNum(_ n: Int) -> Expr {
    let e = MemoryLayout<Int>.size == 4 ? Z3_mk_int(ctx, Int32(n), int_type)
                                        : Z3_mk_int64(ctx, Int64(n), int_type)
    guard e != nil else {
      Syslog.error { "Z3 typedSymbol failed" }
      return mkBot
    }
    return Z3Expr(ctx, expr: e!)
  }

  // assertion and checking
  func ensure(_ formula: Expr) {
    if (optimize == nil) {
		  Z3_solver_assert(ctx, solver!, formula.expr)
    } else {
		  Z3_optimize_assert(ctx, optimize!, formula.expr)
    }
	}

  func ensureCheck(formula: Expr) -> Bool {
		ensure(formula)
		return isSatisfiable
	}

  func maximize(_ expr: Expr) {
    guard optimize != nil else {
      Syslog.error { "Z3 maximization is only available in optimization mode" }
      return
    }

    Z3_optimize_maximize(ctx, optimize, expr.expr)
  }

  func minimize(_ expr: Expr) {
    guard optimize != nil else {
      Syslog.error { "Z3 maximization is only available in optimization mode" }
      return
    }

    Z3_optimize_maximize(ctx, optimize, expr.expr)
  }

	var isSatisfiable: Bool {
    let res = optimize == nil ? Z3_solver_check(ctx, solver!)
                              : Z3_solver_check(ctx, optimize!)
    switch res {
      case Z3_L_TRUE:
        return true
      case Z3_L_FALSE:
        return false
      default:
        print("-------------------------------------------------------")
        assert(false)
        return true
      }
	}

  var model : Model? {
    guard isSatisfiable else { return nil }
    return optimize == nil ? Model(self, Z3_solver_get_model(ctx, solver!))
                           : Model(self, Z3_optimize_get_model(ctx, optimize!))
  }
}
