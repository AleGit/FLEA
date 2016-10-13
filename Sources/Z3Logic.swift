import CZ3Api

final class Z3RawContext{
  fileprivate var raw: Z3_context

  init() {
    raw = Z3_mk_context(Z3_mk_config())
  }

  deinit {
	  Z3_del_context(raw)
  }
}

public final class Z3Expr : LogicExpr {
  fileprivate var expr: Z3_ast
  fileprivate var ctx: Z3RawContext

  init(_ c: Z3RawContext, expr: Z3_ast) {
    self.expr = expr
    self.ctx = c
    Z3_inc_ref(c.raw, self.expr)
  }

  deinit {
    Z3_dec_ref(ctx.raw, self.expr)
  }

  func clear() {
    Z3_dec_ref(ctx.raw, self.expr)
  }

  func not() -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_not(ctx.raw, expr))
  }

  func and(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_and(ctx.raw, UInt32(2), [expr, t.expr]))
  }

  func or(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_or(ctx.raw, 2, [expr, t.expr]))
  }

  func implies(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_implies(ctx.raw, expr, t.expr))
  }

  func iff(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_iff(ctx.raw, expr, t.expr))
  }

  func xor(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_xor(ctx.raw, expr, t.expr))
  }

  func ite(_ t: Z3Expr, _ f: Z3Expr) -> Z3Expr {
      return Z3Expr(ctx, expr: Z3_mk_ite(ctx.raw, expr, t.expr, f.expr))
  }

  // arithmetic operators
  func eq(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_eq(ctx.raw, expr, t.expr))
  }

  func neq(_ t: Z3Expr) -> Z3Expr {
    return !Z3Expr(ctx, expr: Z3_mk_eq(ctx.raw, expr, t.expr))
  }

  func gt(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_gt(ctx.raw, expr, t.expr))
  }

  func ge(_ t: Z3Expr) -> Z3Expr {
    return Z3Expr(ctx, expr: Z3_mk_ge(ctx.raw, expr, t.expr))
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
    return Z3Expr(ctx, expr: Z3_mk_add(ctx.raw, 2, [expr, t.expr]))
  }
  
  
	// term deconstruction
  /// Get children of a Z3 term.
  var children : [Z3Expr] {
    guard (Z3_get_ast_kind(ctx.raw, expr) == Z3_APP_AST) else {
       return []
    }
    let app = Z3_to_app(ctx.raw, self.expr)
    let numargs = Z3_get_app_num_args(ctx.raw, app)
    return (0..<numargs).map {
      Z3Expr(ctx, expr: Z3_get_app_arg(ctx.raw, app, $0))
    }
  }
}

public final class Z3Model : LogicModel {
  typealias Expr = Z3Expr

  fileprivate var ctx : Z3RawContext
  fileprivate var model: Z3_model

  init?(_ ctx: Z3RawContext, _ model: Z3_model) {
    self.model = model
    self.ctx = ctx
    Z3_model_inc_ref(ctx.raw, model)
  }

  deinit {
    Z3_model_dec_ref(ctx.raw, model)
  }

  // evaluation
  /// Evaluate a boolean term `t`
  func eval(_ term: Expr) -> Z3_ast? {
    let cap = MemoryLayout<Int>.size
    let p = UnsafeMutablePointer<Z3_ast?>.allocate(capacity: cap)
    p.initialize(to: nil)

    // set model completion to true
    guard Z3_model_eval(ctx.raw, model, term.expr, Z3_TRUE,p) == Z3_TRUE  else {
      Syslog.error { "Z3 evaluation failed" }
      return nil
    }
    return p.pointee
  }

  /// Evaluate a boolean term `t`
  func evalBool(_ term: Expr) -> Bool? {
    assert (Z3_get_sort(ctx.raw, term.expr) == Z3_mk_bool_sort(ctx.raw))
    guard let val = eval(term) else { return nil }
    return Z3_get_bool_value(ctx.raw, val) == Z3_L_TRUE
  }

  /// Evaluate a term `t` of integer type
  func evalInt(_ term: Expr) -> Int? {
    assert (Z3_get_sort(ctx.raw, term.expr) == Z3_mk_int_sort(ctx.raw))
    var num : Int32 = 0
    guard let val = eval(term) else { return nil }
    guard Z3_get_numeral_int(ctx.raw, val, &num) == Z3_TRUE  else {
      Syslog.error { "Z3 numeral conversion failed" }
      return nil
    }
    return Int(num)
  }

  func implies(formula: Expr) -> Bool {
    guard let v = evalBool(formula) else { return false}
    return v
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
    guard let cstring = Z3_ast_to_string(expr.ctx.raw, expr.expr) else {
      Syslog.error { "could not create String from Z3 expression" }
      return nil
    }
    guard let string = String(validatingUTF8:cstring) else { return nil }
    self = string
  }

  /// Creates a String representation of a Z3 model
  public init?(model: Z3Model) {
    guard let cstring = Z3_model_to_string(model.ctx.raw, model.model) else {
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

  fileprivate var ctx : Z3RawContext
  private var solver: Z3_solver? = nil
  private var optimize: Z3_optimize? = nil

  // last results: has to be cleared in assertions
  var last_model : Z3Model?
  var last_is_sat : Bool?

  // types
  let bool_type : Z3_sort
  let int_type : Z3_sort
  var free_type : Z3_sort

	// special constants
	var 🚧 : Expr

  init(optimize opt: Bool) {
    ctx = Z3RawContext()
    if (opt) {
      self.optimize = Z3_mk_optimize(ctx.raw)
      Z3_optimize_inc_ref(ctx.raw, self.optimize!)
    } else{
      solver = Z3_mk_solver(ctx.raw)
      Z3_solver_inc_ref(ctx.raw, solver!)
    }

    mkTop = Z3Expr(ctx, expr: Z3_mk_true(ctx.raw))
    mkBot = Z3Expr(ctx, expr: Z3_mk_false(ctx.raw))
    🚧 = mkBot // dummy

    bool_type = Z3_mk_bool_sort(ctx.raw)
    int_type = Z3_mk_int_sort(ctx.raw)
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
    last_model = nil

    if (optimize != nil) {
      Z3_optimize_dec_ref(ctx.raw, optimize!)
    } else {
      Z3_solver_dec_ref(ctx.raw, solver!)
    }
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
    return Z3Expr(ctx, expr: Z3_mk_or(ctx.raw, UInt32(ts.count),
                  Expr.toZ3Array(ts)))
  }

  func mkAnd(_ ts: [Expr]) -> Expr {
    return Z3Expr(ctx, expr: Z3_mk_and(ctx.raw, UInt32(ts.count),
                  Expr.toZ3Array(ts)))
  }
  
  func freshVar(_ name: String, _ type: ExprType) -> Expr  {
    let v = Z3_mk_const(ctx.raw, Z3_mk_string_symbol(ctx.raw, name), type)
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
    return Z3_mk_uninterpreted_sort(ctx.raw, Z3_mk_string_symbol(ctx.raw, name))
  }

  private func typedSymbol(_ symbol: String, _ type: ExprType) -> Expr {
    assert(!symbol.isEmpty, "a symbol name must not be empty")
    let c = Z3_mk_const(ctx.raw, Z3_mk_string_symbol(ctx.raw, symbol), type)
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

    let n = UInt32(args.count)
    let dom = domain(args.count, free_type)
    let sym = Z3_mk_string_symbol(ctx.raw, symbol)
    let decl = Z3_mk_func_decl(ctx.raw, sym, n, dom, range)
    return Z3Expr(ctx, expr: Z3_mk_app(ctx.raw, decl, n, args.map{ $0.expr }))
  }

  func mkNum(_ n: Int) -> Expr {
    let e = MemoryLayout<Int>.size == 4 ? Z3_mk_int(ctx.raw, Int32(n), int_type)
                                        : Z3_mk_int64(ctx.raw,Int64(n),int_type)
    guard e != nil else {
      Syslog.error { "Z3 typedSymbol failed" }
      return mkBot
    }
    return Z3Expr(ctx, expr: e!)
  }

  // assertion and checking
  private func resetResult() {
    last_is_sat = nil
    last_model = nil
  }

  func ensure(_ formula: Expr) {
    resetResult()
    if (optimize == nil) {
		  Z3_solver_assert(ctx.raw, solver!, formula.expr)
    } else {
		  Z3_optimize_assert(ctx.raw, optimize!, formula.expr)
    }
	}

  func ensureCheck(formula: Expr) -> Bool {
		ensure(formula)
		return isSatisfiable
	}

  func maximize(_ expr: Expr) {
    resetResult()
    guard optimize != nil else {
      Syslog.error { "Z3 maximization is only available in optimization mode" }
      return
    }

    Z3_optimize_maximize(ctx.raw, optimize!, expr.expr)
  }

  func minimize(_ expr: Expr) {
    resetResult()
    guard optimize != nil else {
      Syslog.error { "Z3 maximization is only available in optimization mode" }
      return
    }

    Z3_optimize_minimize(ctx.raw, optimize!, expr.expr)
  }

	var isSatisfiable: Bool {
    if last_is_sat == nil  {
      let res = (optimize == nil) ? Z3_solver_check(ctx.raw, solver!)
                                  : Z3_optimize_check(ctx.raw, optimize!)
      switch res {
        case Z3_L_TRUE:
          last_is_sat = true
        case Z3_L_FALSE:
          last_is_sat = false
        default:
          print("-------------------------------------------------------")
          assert(false)
        }
    }
    return last_is_sat!
	}

  var model : Model? {
    if last_model == nil {
      guard isSatisfiable else { return nil }
      guard let m = (optimize == nil) ? Z3_solver_get_model(ctx.raw, solver!)
                                      : Z3_optimize_get_model(ctx.raw,optimize!)
        else { return nil }
      last_model = Model(ctx, m)
    }
    return last_model!
  }

  private func getOpt(max: Bool, _ i: Int) -> Int? {
    let ui = UInt32(i)
    guard optimize != nil else {
      Syslog.error { "Z3 maximization is only available in optimization mode" }
      return nil
    }

    guard let val = max ? Z3_optimize_get_upper(ctx.raw, optimize!, ui)
                        : Z3_optimize_get_lower(ctx.raw, optimize!, ui) else {
      return nil
    }

    var num : Int32 = 0
    guard Z3_get_numeral_int(ctx.raw, val, &num) == Z3_TRUE  else {
      Syslog.error { "Z3 numeral conversion failed" }
      return nil
    }
    return Int(num)
  }

  func getMax(i: Int = 0) -> Int? {
    return getOpt(max: true, i)
  }

  func getMin(i: Int = 0) -> Int? {
    return getOpt(max: false, i)
  }
}
