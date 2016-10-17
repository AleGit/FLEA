import CYices

extension Node where Symbol : Hashable {
  var isVar :  Bool {
    return nodes == nil
  }

  var funs: Set<Symbol> {
    var fs: Set<Symbol> = []
    for p in self.positions {
      let t_p = self[p]!
      guard !t_p.isVar else { continue }

      fs.insert(t_p.symbol)
    }
    return fs
  }

  static func trsFuns(_ trs: [(Self, Self)]) -> Set<Symbol> {
    var fs: Set<Symbol> = []
    for (l, r) in trs {
      fs = fs.union(l.funs).union(r.funs)
    }
    return fs
  }

  func varCount() -> [Symbol : Int] {
    var map : [Symbol : Int] = [:]
    for p in self.positions {
      let t_p = self[p]!
      guard t_p.isVar else { continue }

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
  fileprivate var vars : [String: C.Expr] // precedence variables

  init(_ c: C, trs : [(N,N)]) {
    context = c
    vars = [:]
    for sym in N.trsFuns(trs) {
      vars[sym] = context.mkIntVar(sym)
    }
  }

  func printEval(_ model: C.Model) {
    let var_vals : [(String, Int)] = vars.map {
      (f: String, pvar: C.Expr) -> (String, Int) in
      return (f, model.evalInt(pvar)!)
    }
    let fs = var_vals.sorted(by: { $0.1 > $1.1 })
    guard (fs.count > 1) else { return }

    print(fs[0])
    for (f, _) in fs {
      print(" > ", f)
    }
  }
}


final class LPO<N:Node, C: LogicContext> 
where N.Symbol == String {
	typealias E = C.Expr

  var context: C
  var prec: Precedence<C, N>

  init(ctx : C, trs: [(N, N)]) {
    prec = Precedence<C, N>(ctx, trs: trs)
    context = ctx
  }

  private func lex(_ ls:[N], _ rs:[N]) -> E {
    for (li, ri) in zip(ls, rs) {
      if !li.isEqual(to:ri) {
        return self.gt(li, ri)
      }
    }
    return context.mkBot
  }

  func gt(_ l:N, _ r:N) -> E {
    guard !l.isVar else { return context.mkBot }
      guard !r.isSubnode(of:l) else { return context.mkTop }
      guard !r.isVar else { return context.mkBot } // subterms already handled

      let case1 = context.mkOr(l.nodes!.map({ gt($0, r) }))
      if l.symbol != r.symbol {
        let case2 = (prec.vars[l.symbol]! ≻ prec.vars[r.symbol]!) ⋀
                     context.mkAnd(r.nodes!.map { gt(l, $0) })
        return case1 ⋁ case2
      } else {
        let case3 = lex(l.nodes!, r.nodes!)
        return case1 ⋁ case3
      }
    }

  func printEval(_ model: C.Model) {
    print("LPO")
    prec.printEval(model)
  }
}


final class KBO<C: LogicContext, N: Node>
where N.Symbol == String {
	typealias E = C.Expr

  var context: C
  var prec: Precedence<C, N>
  var fun_weights: [String: E] = [:]
  var w0: E

  init(c : C, trs: [(N, N)]) {
    prec = Precedence<C, N>(c, trs: trs)
    context = c
    w0 = context.mkIntVar("w0")
    for sym in N.trsFuns(trs) {
      fun_weights[sym] = context.mkIntVar(sym)
    }
  }

  func weight(_ t: N) -> E {
    guard !t.isVar else { return w0 }

    let w_t_root = fun_weights[t.symbol]!
    return t.nodes!.reduce(w_t_root, { $0.add(weight($1)) })
  }

  func lex(_ ls:[N], _ rs:[N]) -> E {
    for (li, ri) in zip(ls, rs) {
      if !li.isEqual(to:ri) {
        return self.gt(li, ri)
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

  func gt(_ l:N, _ r:N) -> E {
    guard !l.isVar && nonduplicating(l, r) else { return context.mkBot }
    guard !r.isSubnode(of:l) else { return context.mkTop }
    guard !r.isVar else { return context.mkBot } // subterm case already handled

    let w_l = weight(l)
    let w_r = weight(r)

    let dec = l.symbol != r.symbol ? prec.vars[l.symbol]! ≻ prec.vars[r.symbol]!
		                               : lex(l.nodes!, r.nodes!)
    return (w_l ≻ w_r) ⋁ ((w_l ≽ w_r) ⋀ dec)
  }

  func printEvalWeight(_ model: C.Model) {
    print(" w0 = ", model.evalInt(w0)!)

    for (f, w_var) in fun_weights {
      print(" w(", f, ") = ", model.evalInt(w_var)!)
    }
  }

  func printEval(_ model: C.Model) {
    print("KBO")
    prec.printEval(model)
    printEvalWeight(model)
  }
}
