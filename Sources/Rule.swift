
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


final class Rule<N:Node> where N:SymbolStringTyped, N:Hashable {
	let lhs: N
	let rhs: N

	init(_ l:N, _ r:N) {
		lhs = l
		rhs = r
	}

	var terms : (N,N) { return (self.lhs, self.rhs) }

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

  // Return resulting critical pair if <inner, p, outer> is an overlap and the
	// result is nontrivial. The result gets normalized.
	static func cp (inner: Rule, at p: Position, outer: Rule) -> Rule? {
		let (l2,r2) = (outer.lhs, outer.rhs)
		let inner_r = inner.rename
	  let (l1,r1) = (inner_r.lhs, inner_r.rhs)
    guard let l2_p = l2[p] else { return nil }
		// l2_p is not a variable
    guard l2_p.nodes != nil else { return nil }
		// get unifier
    guard let sigma = l1 =?= l2_p else { return nil }

		let eq = Rule<N>((l2 * sigma).replace(at: p, with: r1 * sigma), r2 * sigma)
		guard eq.lhs != eq.rhs else { return nil }
		return eq.normalize
	}
}
