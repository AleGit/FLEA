/// 't⊥' returns the substitution of all variables in t with constant '⊥'.
postfix func ⊥<N:Node>(t:N) -> N 
where N:StringSymbolTabulating,N.Symbol==N.Symbols.Symbol {
  return t * N(c:"⊥")
}

// MARK: type node convenience initializers to build terms with strings.

extension Node where Self:StringSymbolTabulating, Symbol == Self.Symbols.Symbol {
  init(v:String) {
    let s = Self.symbols.insert(v, .variable)
    self.init(variable:s)
  }

  init(c:String) {
    let s = Self.symbols.insert(c, .function(0))
    self.init(constant:s)
  }

  init(f:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:f)
      return
    }
    let s = Self.symbols.insert(f, .function(nodes.count))
    self.init(symbol:s, nodes:nodes)
  }

  init(p:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:p)
      return
    }
    let s = Self.symbols.insert(p, .predicate(nodes.count))
    self.init(symbol:s, nodes:nodes)
  }
}

// MARK: type node calculated symbol string type property

extension Node where Self:StringSymbolTabulating, Symbol == Self.Symbols.Symbol {
  var symbolStringType : (String,Tptp.SymbolType) {
    return Self.symbols[self.symbol] ?? ("\(self.symbol)",.undefined)
  }
}
