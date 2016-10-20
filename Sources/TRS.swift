
struct TRS<N:Node> : Sequence where N:SymbolStringTyped, N:Hashable {
  typealias Symbol = N.Symbol

  var rules: [Rule<N>]

  init() {
		rules = []
	}

  init(_ rs: [Rule<N>]) {
		rules = rs
	}

	func makeIterator() -> TRSIterator<N> {
			return TRSIterator<N>(self)
	}

	mutating func add(_ rule: Rule<N>) {
		rules +=  [rule]
	}

  var funs: [Symbol: Int] {
    var fs: [Symbol: Int] = [:]
    for rule in rules {
      fs.update(other: rule.lhs.funs)
      fs.update(other: rule.rhs.funs)
    }
    return fs
  }

	var symm: TRS {
		return TRS(self.rules + self.rules.map { $0.flip })
	}

	func filter(_ pred : (Rule<N>) -> Bool) -> TRS<N> {
		return TRS(rules.filter(pred))
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
