final class Maxcomp<N:Node, O: Order, C: OptLogicContext>
where O.NodeType == N, O.LogicContextType == C {
  typealias Expr = C.Expr
	typealias ES = TRS<N>

  var order: O
  var context : C

  init(_ es0: ES) {
		context = C(optimize: true)
    order = O(ctx: context, trs: es0)
	}

  func maxTerm(_ es: TRS<N>) -> TRS<N>? {
		let zero = context.mkNum(0)
		var sum = zero
		let es_symm = es.symm
    for c in es_symm {
			sum = sum + ite(order.gt(c.lhs, c.rhs), context.mkNum(1), zero)
		}
		context.push()
		guard let _ = context.maximize(sum) else { return nil }
		guard let m = context.model else { return nil }
    context.pop()
		return es_symm.filter { m.evalBool(order.gt($0.lhs,$0.rhs)) == true }
	}

	func extend(_ es: TRS<N>, with trs: TRS<N>) -> TRS<N> {
		return trs.cps.simplifiedNontrivial(with: trs)
	}

  // find complete TRS, return nil upon failure
  func complete(_ es: ES, max_steps: Int) -> TRS<N>? {
		print("max ", max_steps)
		print("got ES: ", es)
		guard max_steps > 0 else { print("maximal steps reached"); return nil }

		guard var trs = maxTerm(es) else { return nil }
		print("got TRS: ", trs)
		trs = trs.reduced
		print("reduced: ", trs)
		let s = extend(es, with: trs)
		let es_simp = es.simplifiedNontrivial(with: trs)
		if s.isEmpty && es_simp.isEmpty {
			return trs
		}
		return complete(es.union(es_simp).union(s), max_steps: max_steps - 1)
	}
}