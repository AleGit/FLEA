
struct Precedence<C: LogicContext, N: Node>
where N:SymbolStringTyped, N:CustomStringConvertible {
  typealias E = C.Expr

  var context: C
  fileprivate var vars : [String: C.Expr] // precedence variables

  init(_ c: C, trs : TRS<N>) {
    context = c
    vars = [:]
    for (sym, _) in trs.funs {
      let name = "\(sym)"
      vars[name] = context.mkIntVar(name)
    }
  }

  subscript (_ sym : N.Symbol) -> E? { return vars["\(sym)"] }

  func printEval(_ model: C.Model) {
    let var_vals : [(String, Int)] = vars.map {
      (f: String, pvar: C.Expr) -> (String, Int) in
      return (f, model.evalInt(pvar)!)
    }
    let fs = var_vals.sorted(by: { $0.1 > $1.1 })
    guard (fs.count > 1) else { return }

    var s : String = ""
    for (f, _) in fs {
      s = s.characters.count == 0 ? f : s + " > " + f
    }
		print(" " + s)
  }
}

protocol Order {
  associatedtype NodeType : SymbolStringTyped, CustomStringConvertible, Node
  associatedtype LogicContextType : LogicContext

	typealias E = LogicContextType.Expr
  init(ctx : LogicContextType, trs: TRS<NodeType>)
	func gt(_ l:NodeType, _ r:NodeType) -> E
  func printEval(_ model: LogicContextType.Model)
}

final class LPO<N:Node, C: LogicContext> : Order
where N:SymbolStringTyped, N:CustomStringConvertible {
	typealias E = C.Expr
	typealias NodeType = N
	typealias LogicContextType = C

  var context: C
  var prec: Precedence<C, N>

  init(ctx : C, trs: TRS<N>) {
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
    guard !l.isVar && !l.isEqual(to: r) else { return context.mkBot }
      guard !r.isSubnode(of:l) else { return context.mkTop}
      guard !r.isVar else { return context.mkBot } // subterms already handled

      let case1 = context.mkOr(l.nodes!.map({ gt($0, r) }))
      if l.symbol != r.symbol {
        let case2 = (prec[l.symbol]! ≻ prec[r.symbol]!) ⋀
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


final class KBO<N:Node, C: LogicContext> : Order
where N:SymbolStringTyped, N:CustomStringConvertible {
	typealias E = C.Expr
	typealias NodeType = N
	typealias LogicContextType = C

  var context: C
  var prec: Precedence<C, N>
  var fun_weight: [String: E] = [:]
  var w0: E

  init(ctx : C, trs: TRS<N>) {
    prec = Precedence<C, N>(ctx, trs: trs)
    context = ctx
    w0 = context.mkIntVar("w0")
    for (sym, _) in trs.funs {
      let name = "\(sym)"
      fun_weight[name] = context.mkIntVar(name)
    }
		context.ensure(admissible(for: trs))
  }

  func weight(_ t: N) -> E {
    guard !t.isVar else { return w0 }

    let w_t_root = fun_weight["\(t.symbol)"]!
    return t.nodes!.reduce(w_t_root, { $0.add(weight($1)) })
  }

	func admissible(for trs: TRS<N>) -> E {
		let zero = context.mkNum(0)
		var adm = w0 ≻ zero

    for (g, a) in trs.funs {
      let w_g = fun_weight["\(g)"]!
      if (a == 0) {
			  adm = adm ⋀ w_g ≽ w0
			} else if (a == 1) {
				var max = context.mkTop
				let p_g = prec[g]!
        for (f, _) in trs.funs {
					guard f != g else { continue }
			    max = max ⋀ p_g ≻ prec[f]!
				}
			  adm = adm ⋀ w_g ≽ zero ⋀ (w_g == zero ⟹ max)
			} else {
			  adm = adm ⋀ w_g ≽ zero
			}
    }
		return adm
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
    guard !l.isVar && nonduplicating(l, r) && !l.isEqual(to: r) else {
			return context.mkBot
		}
    guard !r.isSubnode(of:l) else { return context.mkTop }
    guard !r.isVar else { return context.mkBot } // subterm case already handled

    let w_l = weight(l)
    let w_r = weight(r)

    let dec = l.symbol != r.symbol ? prec[l.symbol]! ≻ prec[r.symbol]!
		                               : lex(l.nodes!, r.nodes!)
    return (w_l ≻ w_r) ⋁ ((w_l ≽ w_r) ⋀ dec)
  }

  func printEvalWeight(_ model: C.Model) {
    print(" w0 = ", model.evalInt(w0)!)

    for (f, w_var) in fun_weight {
      print(" w(\(String(f)!)) = ", model.evalInt(w_var)!)
    }
  }

  func printEval(_ model: C.Model) {
    print("KBO")
    prec.printEval(model)
    printEvalWeight(model)
  }
}
