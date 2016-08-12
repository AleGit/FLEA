/// 't⊥' returns the substitution of all variables in t with constant '⊥'.
postfix func ⊥<N:Node where N.Symbol:StringSymbolable>(t:N) -> N {
    return t * N(c:"⊥")
}

// MARK: type node convenience initializers to build terms with strings.

extension Node where Symbol:StringSymbolable {
  init(v:String) {
    let s = Symbol(v,.variable)
    self.init(variable:s)
  }

  init(c:String) {
    let s = Symbol(c,.function(0))
    self.init(constant:s)
  }

  init(f:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:f)
      return
    }
    let s = Symbol(f,.function(nodes.count))
    self.init(symbol:s, nodes:nodes)
  }

  init(p:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:p)
      return
    }
    let s = Symbol(p,.predicate(nodes.count))
    self.init(symbol:s, nodes:nodes)
  }
}

// MARK: type node calculated symbol string type property

extension Node where Symbol:StringSymbolable {
  var stringSymbolType : (String,Tptp.SymbolType) {
    return (self.symbol.string, self.symbol.type)
  }
}


// MARK:

extension Node where Symbol:StringSymbolable {
  /// convert node types
  init<N:Node where N.Symbol:StringSymbolable>(_ other:N) {
    let s = Symbol(other.symbol.string,other.symbol.type)
    let nodes = other.nodes?.map { Self($0) }
    self.init(symbol:s, nodes:nodes)
  }
}
