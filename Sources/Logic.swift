import CYices


protocol Logic {
  associatedtype Term
  associatedtype Model

  init()

  // logical operators
  var top : Term { get }
  var bot : Term { get }
  func not(_ t: Term) -> Term
  func and(_ s : Term, _ t: Term) -> Term
  func and(_ ts: [Term]) -> Term
  func or(_ s: Term, _ t: Term) -> Term
  func or(_ ts: [Term]) -> Term
  func implies(_ s: Term, _ t: Term) -> Term

  // arithmetic operators
  func eq(_ s: Term, _ t: Term) -> Term
  func neq(_ s: Term, _ t: Term) -> Term
  func gt(_ s: Term, _ t: Term) -> Term
  func ge(_ s: Term, _ t: Term) -> Term
  func add(_ s : Term, _ t: Term) -> Term

  // create terms
  func freshBoolVar(_ name: String) -> Term
  func freshIntVar(_ name: String) -> Term

  // evaluation
  func evalBool(_ model: Model, _ term: Term) -> Bool
  func evalInt(_ model: Model, _ term: Term) -> Int
}


struct YicesLogic : Logic {
  typealias Term = term_t
  typealias Model = OpaquePointer

  var bool_type = yices_bool_type()
  var int_type = yices_int_type()
  var ctx : OpaquePointer

  init() {
    ctx = yices_new_context(nil)
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

  // evaluation
  func evalBool(_ model: Model, _ t: Term) -> Bool {
		var p : Int32 = 0
    let success = yices_get_bool_value(model, t, &p)
    // FIXME: rather throw exception
    guard success == 0  else {
      yices_print_error(stdout)
      return false
    }
    return  (p != 0)
  }

  func evalInt(_ model: Model, _ t: Term) -> Int {
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
