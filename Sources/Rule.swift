
extension Dictionary {
  mutating func update(other:Dictionary) {
    for (k,v) in other {
      self.updateValue(v, forKey:k)
    }
  }
}


extension Node where Self:SymbolStringTyped, Symbol:Hashable {
  var isVar :  Bool {
    return nodes == nil
  }

  func replace(at p: Position, with s: Self) -> Self {
	  guard let (i, q) = p.decomposing else { return s }

		var args = self.nodes!
		args[i] = args[i].replace(at: Position(q), with: s)
		return Self(symbol: self.symbol, nodes: args) 
	}

  var funs: [Symbol: Int] {
    var fs: [Symbol: Int] = [:]
    for p in self.positions {
      let t_p = self[p]!
      guard !t_p.isVar else { continue }

      fs[t_p.symbol] = t_p.nodes!.count
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

	var funsPos : [Position] {
		return positions.filter { self[$0]!.nodes != nil}
	}

  // Canonical variable name for integer i
	// FIXME: use variables of type int!
  private static func ithVar(_ i:Int) -> String {
		switch i {
			case 0: return "X"
			case 1: return "Y"
			case 2: return "Z"
			default: return "X\(String(i))"
	  }
	}

  // Canonically rename variables in a Node, using replacement map sub and
	// next variable index
  private func normalize(_ sub: inout [Symbol:String], _ index: inout Int)
	             -> Self {
    if self.nodes == nil {
			if sub[self.symbol] == nil {
				sub[self.symbol] = Self.ithVar(index)
				index += 1
			}
      return Self(v:sub[self.symbol]!)
		}
		return Self(symbol: self.symbol,
		            nodes: self.nodes!.map { $0.normalize(&sub, &index)})
	}

  // Canonically rename variables in a Node
	var normalize : Self {
		var sub : [Symbol:String] = [:]
		var index = 0
		return self.normalize(&sub, &index)
	}
}


final class Rule<N:Node> : Hashable, CustomStringConvertible
            where N:SymbolStringTyped, N:Hashable {
	let lhs: N
	let rhs: N

	init(_ l:N, _ r:N) {
		lhs = l
		rhs = r
	}

	var terms : (N,N) { return (self.lhs, self.rhs) }

	var hashValue: Int {
			return lhs.hashValue ^ rhs.hashValue
	}

	static func == (rl1: Rule, rl2: Rule) -> Bool {
	  return rl1.lhs.isEqual(to: rl2.lhs) && rl1.rhs.isEqual(to: rl2.rhs)
	}

	var nontrivial : Bool {
		return !lhs.isEqual(to: rhs)
	}

	var flip : Rule {
		return Rule(rhs, lhs)
	}

	var rename : Rule {
		return Rule<N>(self.lhs.appending(suffix: "#"),
		               self.rhs.appending(suffix: "#"))
	}

  // Canonically rename variables in a Rule
	var normalize : Rule {
		let t = N(f:"=", [self.lhs, self.rhs]).normalize
		return Rule<N>(t.nodes![0], t.nodes![1])
	}

  // Return resulting critical pair if <inner, p, self> is an overlap and the
	// result is nontrivial. The result gets normalized.
	// Rules do not get renamed.
	func cp (inner: Rule, at p: Position) -> Rule? {
		let (l2,r2) = (self.lhs, self.rhs)
	  let (l1,r1) = (inner.lhs, inner.rhs)
    guard let l2_p = l2[p] else { return nil }
		// l2_p is not a variable
    guard l2_p.nodes != nil else { return nil }
		// get unifier
    guard let sigma = l1 =?= l2_p else { return nil }

		let eq = Rule<N>((l2 * sigma).replace(at: p, with: r1 * sigma), r2 * sigma)
		guard eq.lhs != eq.rhs else { return nil }
		return eq.normalize
	}

  // Return critical pairs with inner.
	// Rules do not get renamed.
	func cps (with inner: Rule) -> [Rule] {
		let eqs = lhs.funsPos.map { return cp(inner: inner, at: $0) }
		return eqs.filter{$0 != nil}.map {$0!}
	}

  // Return critical pairs with trs. Variables get renamed, results normalized.
	func cps (with trs: TRS<N>) -> TRS<N> {
		let rule = self.rename
    return trs.flatMap{ TRS<N>(rule.cps(with:$0)) }
	}

	var description: String {
		return String(describing: lhs) + " -> " + String(describing: rhs)
  }
}


fileprivate extension Dictionary where Value : Node, Value : Hashable {
	// Add k -> v mapping if substitution stays consistent, otherwise return false
	mutating func add(k: Key, v:Value) -> Bool {
		guard let v0 = self[k] else {
			self[k] = v
			return true
		}
		return v0.isEqual(to: v)
	}
}


extension Node where Self:SymbolStringTyped, Symbol:Hashable {
	typealias Subst = [Self:Self]

  private func match(_ lhs: Self, with σ: inout Subst) -> Bool {
		if lhs.isVar {
			return σ.add(k: lhs, v: self)
		}

		guard lhs.symbol == self.symbol else { return false }
		var res = true
		for (ti, li) in zip(self.nodes!, lhs.nodes!) {
			res = res && ti.match(li, with: &σ)
		}
    return res
	}

  func match(_ lhs: Self) -> Subst? {
		var σ = Subst()
		guard match(lhs, with: &σ) else { return nil }
	  return σ
	}

	private func rewrite_step (with rule: Rule<Self>, at pos:Position) -> Self? {
		guard let t_p = self[pos] else { return nil }
    guard let σ = t_p.match(rule.lhs) else { return nil }
    return replace(at:pos, with: rule.rhs * σ)
	}

	func applySubst(_ σ: Subst) -> Self { return self * σ }

	func rewrite_step (with rule: Rule<Self>) -> Self? {
		for p in self.funsPos {
      let t = rewrite_step(with: rule, at: p)
			if t != nil {
				return t
			}
		}
		return nil
	}

	func nf (with trs: TRS<Self>) -> Self {
		guard !isVar else { return self }

	  for rule in trs.rules {
      let u = rewrite_step(with: rule)
			if u != nil {
				return (u!).nf(with: trs)
			}
		}
		return self
	}

	func isReducible (with trs: TRS<Self>) -> Bool {
    guard !isVar else { return false }

    for rule in trs.rules {
      let u = rewrite_step(with: rule)
			if u != nil {
				return true
			}
		}
		return false
	}
}
