import CYices

extension Node {
  var isVar :  Bool {
    return nodes == nil
  }

  func varCount() -> [Symbol : Int] {
    var map : [Symbol : Int] = [:]
    for p in self.positions {
      let t_p = self[p]!
      guard !t_p.isVar else { continue }

      guard let k = map[t_p.symbol] else {
        map[t_p.symbol] = 1
        continue
      }
      map[t_p.symbol] = k + 1
    }
    return map
  }
}


struct Precedence<C: LogicContext, N: Node>
where N.Symbol == String {

  var context: C
  var vars : [String: C.Expr] // precedence variables

  init(_ c: C) {
    context = c
    vars = [:]
  }

  mutating func get(_ sym: N.Symbol) -> C.Expr {
    if let prec_var = vars[sym] {
      return prec_var
    } else {
      let prec_var = context.mkIntVar(sym)
      vars[sym] = prec_var
      return prec_var
    }
  }

  func printEval(_ model: C.Model) {
    let var_vals : [(String, Int)] = vars.map {
      (f: String, pvar: C.Expr) -> (String, Int) in
      return (f, context.evalInt(model, pvar))
    }
    let fs = var_vals.sorted(by: { $0.1 > $1.1 })
    guard (fs.count > 1) else { return }

    print(fs[0])
    for (f, _) in fs {
      print(" > ", f)
    }
  }
}


struct LPO<C: LogicContext, N: Node>
where N.Symbol == String {
  var context: C
  var prec: Precedence<C, N>

  init(ctx : C) {
    prec = Precedence<C, N>(ctx)
    context = ctx
  }

  mutating func lex(_ ls:[N], _ rs:[N]) -> C.Expr {
    for (li, ri) in zip(ls, rs) {
      if !li.isEqual(to:ri) {
        return gt(li, ri)
      }
    }
    return context.mkBot
  }

  mutating func gt(_ l:N, _ r:N) -> C.Expr {
    guard !l.isVar else { return context.mkBot }
      guard !r.isSubnode(of:l) else { return context.mkTop }
      guard !r.isVar else { return context.mkBot } // subterm case already handled

      let case1 = context.mkOr(l.defaultSubnodes.map({ gt($0, r) }))
      if l.symbol != r.symbol {
        let case2 =
          prec.get(l.symbol).ge(prec.get(r.symbol)).and(
                    context.mkAnd(r.defaultSubnodes.map { gt(l, $0) } ))
        return case1.or(case2)
      } else {
        let case3 = lex(l.nodes!, r.nodes!)
        return case1.or(case3)
      }
    }

  func printEval(_ model: C.Model) {
    print("LPO")
    prec.printEval(model)
  }
}


struct KBO<C: LogicContext, N: Node>
where N.Symbol == String {

  var context: C
  var prec: Precedence<C, N>
  var fun_weights: [String: C.Expr] = [:]
  var w0: C.Expr

  init(c : C) {
    prec = Precedence<C, N>(c)
    context = c
    w0 = context.mkIntVar("w0")
  }

  mutating func fun_weight(_ sym: String) -> C.Expr {
    if let w_var = fun_weights[sym] {
      return w_var
    } else {
      let w_var = context.mkIntVar(sym)
      fun_weights[sym] = w_var
      return w_var
    }
  }

  mutating func weight(_ t: N) -> C.Expr {
    guard !t.isVar else { return w0 }

    let w_t_root = fun_weight(t.symbol)
    return t.nodes!.reduce(w_t_root, { $0.add(weight($1)) })
  }


  mutating func lex(_ ls:[N], _ rs:[N]) -> C.Expr {
    for (li, ri) in zip(ls, rs) {
      if !li.isEqual(to:ri) {
        return gt(li, ri)
      }
    }
    return context.mkBot
  }

  func nonduplicating(_ l:N, _ r:N) -> Bool {
    let lvars = l.varCount()
    for (v, r_n) in r.varCount() {
      guard let l_n = lvars[v] else { return false }
      if (r_n > l_n) {
        return false
      }
    }
    return true
  }

  mutating func gt(_ l:N, _ r:N) -> C.Expr {
    guard !l.isVar && nonduplicating(l, r) else { return context.mkBot }
    guard !r.isSubnode(of:l) else { return context.mkTop }
    guard !r.isVar else { return context.mkBot } // subterm case already handled

    let w_l = weight(l)
    let w_r = weight(r)

    var dec: C.Expr
    if l.symbol != r.symbol {
      dec = prec.get(l.symbol).gt(prec.get(r.symbol))
    } else {
      dec = lex(l.nodes!, r.nodes!)
    }
    return w_l.gt(w_r).or( w_l.ge(w_r).and(dec))
  }

  func printEval_weight(_ model: C.Model) {
    print(" w0 = ", context.evalInt(model, w0))

    for (f, w_var) in fun_weights {
      print(" w(", f, ") = ", context.evalInt(model, w_var))
    }
  }

    func printEval(_ model: C.Model) {
        print("KBO")
        prec.printEval(model)
        printEval_weight(model)
    }
}
