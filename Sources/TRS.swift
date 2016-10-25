
struct TRS<N:Node> : Sequence, CustomStringConvertible
       where N:SymbolStringTyped, N:Hashable {
  typealias Symbol = N.Symbol
	typealias R = Rule<N>
	typealias Iterator = TRSIterator<N>

  var rules: Set<R>

  init() {
		rules = Set()
	}

  init(_ rs: Set<R>) {
		rules = rs
	}

  init(_ rs: [R]) {
		rules = Set<R>()
		for r in rs {
		  rules.insert(r)
		}
	}

	func makeIterator() -> Iterator {
			return Iterator(self)
	}

	var isEmpty : Bool { return rules.isEmpty }

	var count: Int { return rules.count }

	mutating func add(_ rule: R) {
		rules.insert(rule)
	}

	mutating func add(_ other: TRS) {
		rules.formUnion(other.rules)
	}

	static func ==(_ trs: TRS, _ other: TRS) -> Bool {
		return trs.rules == other.rules
	}

	func union(_ other: TRS) -> TRS {
		return TRS<N>(rules.union(other.rules))
	}

  var funs: [Symbol: Int] {
    var fs: [Symbol: Int] = [:]
    for rule in rules {
      fs.update(other: rule.lhs.funs)
      fs.update(other: rule.rhs.funs)
    }
    return fs
  }

	func map(_ f : (R) -> R) -> TRS {
		return TRS<N>(rules.map(f))
	}

	func flatMap(_ f : (R) -> TRS) -> TRS {
		return TRS<N>(rules.flatMap { f($0).rules })
	}

	func filter(_ pred : (R) -> Bool) -> TRS {
		return TRS<N>(rules.filter(pred))
	}

	var symm: TRS {
		return union(self.map { $0.flip })
	}

	var normalize: TRS {
		return self.map { $0.normalize }
	}

  // Return critical pairs with trs.
	var cps: TRS {
    return TRS<N>(rules.flatMap{ $0.cps(with: self).rules })
	}

	func simplify(with other: TRS) -> TRS {
		var simp = TRS<N>()
	  for st in self {
			let s = st.lhs.nf(with: other)
			let t = st.rhs.nf(with: other)
      simp.add(R(s, t).normalize)
	  }
		return simp
	}

	func simplifiedNontrivial(with other: TRS) -> TRS {
		return simplify(with: other).filter({ $0.nontrivial })
	}

  // return l->r' such that l->r is in self, l is irreducible an r' = NF(r)
	var reduced: TRS {
		var reduced = TRS<N>()
	  for st in self {
			guard !st.lhs.isReducible(with: reduced) else { continue }
			let t = st.rhs.nf(with: reduced)
			let rule = R(st.lhs, t).normalize

			let new = TRS<N>([ rule ])
			var red = new
			for lr in reduced {
				guard !lr.lhs.isReducible(with: new) else { continue }
				let r = lr.rhs.nf(with: new)
				red.add(R(lr.lhs, r).normalize)
			}
			reduced = red
	  }
		return reduced
	}

	var description: String {
		let s = rules.reduce("{", { $0 + "\n  " + String(describing: $1)})
		return s + "\n}"
  }
}


struct TRSIterator<N:Node> : IteratorProtocol
       where N:SymbolStringTyped, N:Hashable {
	typealias R = Rule<N>
	typealias T = TRS<N>

	let trs: T
	var index : SetIndex<R>

	init(_ trs: T) {
		self.trs = trs
		index = trs.rules.startIndex
	}

	mutating func next() -> R? {
			guard index < trs.rules.endIndex else { return nil }
			let i = index
			trs.rules.formIndex(after: &index)
			return trs.rules[i]
	}
}
