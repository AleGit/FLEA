/// default implementations for SymbolStringTyped
extension Node where Symbol:StringSymbolable {
  var symbolStringType: (String, Tptp.SymbolType) {
    return (self.symbol.string, self.symbol.type)
  }

  static func symbolize(string: String, type: Tptp.SymbolType) -> Symbol {
    return Symbol(string, type)
  }
}

/// default implementations for SymbolStringTyped
extension Node where Self:SymbolTabulating,
Symbol == Self.Symbols.Symbol, Self.Symbols.Key == String {
  var symbolStringType: (String, Tptp.SymbolType) {
    return Self.symbols[self.symbol] ?? ("\(self.symbol)", .undefined)
  }

  static func symbolize(string: String, type: Tptp.SymbolType) -> Symbol {
    return self.symbols.insert(string, type)
  }
}

extension Node where Self:SymbolStringTyped {
  // implies Symbol: Hashable

  /// Creates a term tree where a suffix is added to all variable names
  func appending<T:Any>(separator: String = "_", suffix: T) -> Self {
    guard let nodes = self.nodes else {
      let (string, type) = self.symbolStringType
      Syslog.error(condition: type != .variable) {
        "Node(symbol:\(self.symbol), nodes:nil) must not be of type \(type)."
      }
      let symbol = Self.symbolize(string:"\(string)\(separator)\(suffix)", type:type)
      return Self(symbol:symbol, nodes:nil)
    }

    return Self(symbol:self.symbol, nodes:nodes.map { $0.appending(suffix:suffix) })

  }

  // remove unnecessary suffixes from variable names
  private func desuffixing(separator: String,
  mappings: inout Dictionary<String, String>, symbols: inout Set<String>) -> Self {
    guard let nodes = self.nodes else {
      let (string, type) = self.symbolStringType
      Syslog.error(condition: type != .variable ) {
        "Node with nil nodes must be of type variable."
      }

      if let symbol = mappings[string] {
        return Self(symbol: Self.symbolize(string:symbol, type:.variable), nodes: nil)
      }

      let components = string.components(separatedBy: separator)

      Syslog.error(condition: components.count > 2 ) {
        "Can not handle \(string) with \(components.count) components."
      }

      guard let symbol = components.first else {
        Syslog.error { "Can not handle \(string) with no components." }
        return self
      }

      if symbols.contains(symbol) {
        return self // no renaming
      }

      mappings[string] = symbol
      symbols.insert(symbol)

      return Self(symbol:Self.symbolize(string:symbol, type:.variable), nodes:nil)

    }

    return Self(symbol: self.symbol, nodes: nodes.map {
      $0.desuffixing(separator:separator, mappings:&mappings, symbols:&symbols)}
      )
  }

  @available(*, deprecated, message: "- for experimental purposes only -")
  /// remove unnecessary suffixes
  func desuffixing(separator: String = "_") -> Self {
    Syslog.error(condition: separator.isEmpty) { "Must not use empty suffix separator" }
    var m = Dictionary<String, String>()
    var s = Set<String>()
    return desuffixing(separator:separator, mappings:&m, symbols:&s)
  }

  /* prefix normalization */

  /// f(X,Y,Y).normalizing(prefix:Z) -> f(Z0,Z1,Z1)
  func normalizing<T: Any>(prefix: T, separator: String = "", offset: Int = 0) -> Self {
    var renamings = Dictionary<Symbol, Symbol>()

    return self.normalizing(prefix: prefix, separator: separator, offset: offset,
    renamings: &renamings)
  }

  private func normalizing<T: Any>(prefix: T, separator: String, offset: Int,
  renamings: inout Dictionary<Symbol, Symbol>) -> Self {
    if let nodes = self.nodes {
      // not a variable
      return Self(symbol: self.symbol, nodes: nodes.map {
        $0.normalizing(prefix:prefix, separator:separator, offset:offset, renamings:&renamings)
      })
    }

    if let symbol = renamings[self.symbol] {
      // variable symbol was allready encountered
      return Self(variable:symbol)
    }

    // variable symbol is unknown so far
    let symbol = Self.symbolize(
      string:"\(prefix)\(separator)\(renamings.count+offset)",
      type:.variable)
    renamings[self.symbol] = symbol
    return Self(variable:symbol)

  }

  /* placeholder normalization */

  func normalizing(placeholder: String = "*️⃣") -> (Self, Dictionary<Self, [Position]>) {
    var variables = Dictionary<Self, [Position]>()
    return (
      normalizing(placeholder: placeholder, position: ε, variables: &variables),
      variables)
  }

  func normalizing(placeholder: String, position: Position,
  variables: inout Dictionary<Self, [Position]>) -> Self {

     guard let nodes = self.nodes else {
       var positions = variables[self] ?? [Position] ()
       positions.append(position)
       variables[self] = positions

       return Self(v:placeholder)
     }

     var nnodes = [Self]()

     for (index, node) in nodes.enumerated() {
       let nnode = node.normalizing(placeholder:placeholder,
       position:position + [index], variables:&variables)
       nnodes.append(nnode)
     }

     return Self(symbol:self.symbol, nodes:nnodes)
  }





}
