
final class TRS<N:Node> : Sequence where N:SymbolStringTyped, N:Hashable {
  typealias Symbol = N.Symbol

  var rules: [Rule<N>]

  init(_ rs: [Rule<N>]) {
		rules = rs
	}

  var funs: [Symbol: Int] {
    var fs: [Symbol: Int] = [:]
    for rule in rules {
      fs.update(other: rule.lhs.funs)
      fs.update(other: rule.rhs.funs)
    }
    return fs
  }

	func makeIterator() -> TRSIterator<N> {
			return TRSIterator<N>(self)
	}
}


struct TRSIterator<N:Node> : IteratorProtocol
      where N:SymbolStringTyped, N:Hashable {
	let trs: TRS<N>
	var index = 0

	init(_ trs: TRS<N>) {
		self.trs = trs
	}

	mutating func next() -> Rule<N>? {
			guard index < trs.rules.count else { return nil }
			let i = index
			index += 1
			return trs.rules[i]
	}
}
