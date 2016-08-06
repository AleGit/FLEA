/// 't⊥' returns the substitution of all variables in t with constant '⊥'.
postfix func ⊥<N:Node where N.Symbol:Symbolable>(t:N) -> N {
    return t * N(c:"⊥")
}

// MARK: convenience initializers to build terms with strings.

extension Node where Symbol:Symbolable {
  init(v:String) {
    let s = Symbol(v,.variable)
    self.init(variable:s)
  }

  init(c:String) {
    let s = Symbol(c,.function)
    self.init(constant:s)
  }

  init(f:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:f)
      return
    }
    let s = Symbol(f,.function)
    self.init(symbol:s, nodes:nodes)
  }

  init(p:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:p)
      return
    }
    let s = Symbol(p,.predicate)
    self.init(symbol:s, nodes:nodes)
  }
}

// MARK:

extension Node where Symbol:Symbolable {
  /// convert node types
  init<N:Node where N.Symbol:Symbolable>(_ other:N) {
    let s = Symbol(other.symbol.string,other.symbol.type)
    let nodes = other.nodes?.map { Self($0) }
    self.init(symbol:s, nodes:nodes)
  }
}
