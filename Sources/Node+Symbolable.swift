/// 't⊥' returns the substitution of all variables in t with constant '⊥'.
postfix func ⊥<N:Node>(t:N) -> N 
where N.Symbol:StringSymbolable {
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

  init(f:String, _ nodes:[Self]) {
    let s = Symbol(f,.function(nodes.count))
    self.init(symbol:s, nodes:nodes)
  }

  init(p:String, _ nodes:[Self]) {
    let s = Symbol(p,.predicate(nodes.count))
    self.init(symbol:s, nodes:nodes)
  }
}

// MARK: type node calculated symbol string type property

/// provide default implementations for Node : TypedNode
extension Node where Symbol:StringSymbolable {
  var symbolStringType : (String,Tptp.SymbolType) {
    return (self.symbol.string, self.symbol.type)
  }

  static func symbolize(string:String, type:Tptp.SymbolType) -> Symbol {
    return Symbol(string,type)
  }
}


// MARK:

extension Node where Symbol:StringSymbolable {
  /// convert node types
  init<N:Node>(_ other:N) 
  where N.Symbol:StringSymbolable {
    let s = Symbol(other.symbol.string,other.symbol.type)
    let nodes = other.nodes?.map { Self($0) }
    self.init(symbol:s, nodes:nodes)
  }
}

/* 
extension Node where Self:TypedNode {
  init<N:Node>(_ other:N) 
  where N:TypedNode {
    // TODO
  }
}
*/
