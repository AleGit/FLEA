final class Maxcomp<N:Node, O: Order, C: OptLogicContext>
where N:SymbolStringTyped, N:CustomStringConvertible, O.NodeType == N,
      O.LogicContextType == C {
  typealias Expr = C.Expr

  var order: O
  var context : C

  init(es0: TRS<N>) {
		context = C()
    order = O(ctx: context, trs: es0)
	}

  func maxTerm(es: TRS<N>) -> TRS<N>? {
		let zero = context.mkNum(0)
		var sum = zero
		let es_symm = es.symm
    for c in es_symm {
			sum = sum + (order.gt(c.lhs, c.rhs)).ite(context.mkNum(1), zero)
		}
		guard let _ = context.maximize(sum) else { return nil }
		guard let m = context.model else { return nil }

		return es_symm.filter { m.evalBool(order.gt($0.lhs,$0.rhs)) == true }
	}

}