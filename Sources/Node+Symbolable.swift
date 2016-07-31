/// Symbolable types can be instantiated with strings.
protocol Symbolable {

  var string : String { get }
  var type : Tptp.SymbolType { get }

  init(_ string: String, _ type: Tptp.SymbolType)
}

/// 't⊥' returns the substitution of all variables in t with constant '⊥'.
postfix func ⊥<N:Node where N.Symbol:Symbolable>(t:N) -> N {
    return t * N(c:"⊥")
}

extension Symbolable {
  static var empty : Self {
    return Self("",.undefined)
  }
}

// MARK: convenience initializers to build terms with strings.

extension Node where Symbol:Symbolable {
  init(v:String) {
    self.init(variable:Symbol(v,.variable))
  }

  init(c:String) {
    self.init(constant:Symbol(c,.function))
  }

  init(f:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:f)
      return
    }
    self.init(symbol:Symbol(f,.function), nodes:nodes)
  }

  init(p:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:p)
      return
    }
    self.init(symbol:Symbol(p,.predicate), nodes:nodes)
  }
}