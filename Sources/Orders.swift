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


struct Precedence<L: Logic, N: Node>
where N.Symbol == String {

  var logic: L
  var vars : [String: L.Term] // precedence variables

  init(l: L) {
    logic = l
    vars = [:]
  }

  mutating func get(_ sym: N.Symbol) -> L.Term {
    if let prec_var = vars[sym] {
      return prec_var
    } else {
      let prec_var = logic.freshIntVar(sym)
      vars[sym] = prec_var
      return prec_var
    }
  }

  func printEval(_ model: L.Model) {
    let var_vals : [(String, Int)] = vars.map {
      (f: String, pvar: L.Term) -> (String, Int) in
      return (f, logic.evalInt(model, pvar))
    }
    let fs = var_vals.sorted(by: { $0.1 > $1.1 })
    guard (fs.count > 1) else { return }

    print(fs[0])
    for (f, _) in fs {
      print(" > ", f)
    }
  }
}


struct LPO<L: Logic, N: Node>
where N.Symbol == String {
  var logic: L
  var prec: Precedence<L, N>

  init(l : L) {
    prec = Precedence<L, N>(l: l)
    logic = l
  }

  mutating func lex(_ ls:[N], _ rs:[N]) -> L.Term {
    for (li, ri) in zip(ls, rs) {
      if !li.isEqual(to:ri) {
        return gt(li, ri)
      }
    }
    return logic.bot
  }

  mutating func gt(_ l:N, _ r:N) -> L.Term {
    guard !l.isVar else { return logic.bot }
      guard !r.isSubnode(of:l) else { return logic.top }
      guard !r.isVar else { return logic.bot } // subterm case already handled

      let case1 = logic.or(l.defaultSubnodes.map({ gt($0, r) }))
      if l.symbol != r.symbol {
        let case2 =
          logic.and(logic.ge(prec.get(l.symbol), prec.get(r.symbol)),
                    logic.and(r.defaultSubnodes.map { gt(l, $0) } ))
        return logic.or(case1, case2)
      } else {
        let case3 = lex(l.nodes!, r.nodes!)
        return logic.or(case1, case3)
      }
    }

  func printEval(_ model: L.Model) {
    print("LPO")
    prec.printEval(model)
  }
}


struct KBO<L: Logic, N: Node>
where N.Symbol == String {

  var logic: L
  var prec: Precedence<L, N>
  var fun_weights: [String: L.Term] = [:]
  var w0: L.Term

  init(l : L) {
    prec = Precedence<L, N>(l: l)
    logic = l
    w0 = logic.freshIntVar("w0")
  }

  mutating func fun_weight(_ sym: String) -> L.Term {
    if let w_var = fun_weights[sym] {
      return w_var
    } else {
      let w_var = logic.freshIntVar(sym)
      fun_weights[sym] = w_var
      return w_var
    }
  }

  mutating func weight(_ t: N) -> L.Term {
    guard !t.isVar else { return w0 }

    let w_t_root = fun_weight(t.symbol)
    return t.nodes!.reduce(w_t_root, { logic.add($0, weight($1)) })
  }


  mutating func lex(_ ls:[N], _ rs:[N]) -> L.Term {
    for (li, ri) in zip(ls, rs) {
      if !li.isEqual(to:ri) {
        return gt(li, ri)
      }
    }
    return logic.bot
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

  mutating func gt(_ l:N, _ r:N) -> L.Term {
    guard !l.isVar && nonduplicating(l, r) else { return logic.bot }
    guard !r.isSubnode(of:l) else { return logic.top }
    guard !r.isVar else { return logic.bot } // subterm case already handled

    let w_l = weight(l)
    let w_r = weight(r)

    var dec: L.Term
    if l.symbol != r.symbol {
      dec = logic.gt(prec.get(l.symbol), prec.get(r.symbol))
    } else {
      dec = lex(l.nodes!, r.nodes!)
    }
    return logic.or(logic.gt(w_l, w_r), logic.and(logic.ge(w_l, w_r), dec))
  }

  func printEval_weight(_ model: L.Model) {
    print(" w0 = ", logic.evalInt(model, w0))

    for (f, w_var) in fun_weights {
      print(" w(", f, ") = ", logic.evalInt(model, w_var))
    }
  }

    func printEval(_ model: L.Model) {
        print("KBO")
        prec.printEval(model)
        printEval_weight(model)
    }
}
