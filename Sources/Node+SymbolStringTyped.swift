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
extension Node
where Self:SymbolTabulating, Symbol == Self.Symbols.Symbol, Self.Symbols.Key == String {
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
  func appending<T:Any>(suffix: T) -> Self {
    guard let nodes = self.nodes else {
      let (string, type) = self.symbolStringType
      Syslog.error(condition: type != .variable) {
        "Node(symbol:\(self.symbol), nodes:nil) must not be of type \(type)."
      }
      let symbol = Self.symbolize(string:"\(string)_\(suffix)", type:type)
      return Self(symbol:symbol, nodes:nil)
    }

    return Self(symbol:self.symbol, nodes:nodes.map { $0.appending(suffix:suffix) })

  }

  // remove unnecessary suffixes
  private func normalizing(mappings: inout Dictionary<String, String>,
  symbols: inout Set<String>) -> Self {
    guard let nodes = self.nodes else {
      let (string, type) = self.symbolStringType
      Syslog.error(condition: type != .variable ) {
        "Node with nil nodes must be of type variable."
      }

      if let symbol = mappings[string] {
        return Self(symbol: Self.symbolize(string:symbol, type:.variable), nodes: nil)
      }

      let components = string.components(separatedBy: "_")

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
      $0.normalizing(mappings:&mappings, symbols:&symbols)}
      )
  }

  @available(*, deprecated, message: "- for experimental purposes only -")
  /// remove unnecessary suffixes _
  func normalizing() -> Self {
    var m = Dictionary<String, String>()
    var s = Set<String>()
    return normalizing(mappings:&m, symbols:&s)
  }

  /// Create term tree where variables x,y,z are renamed to prefix_0, prefix_2, prefix_3
  ///
  func normalizing<T: Any>(prefix: T, offset: Int = 0) -> Self {
    var renaming = Dictionary<Symbol, Symbol>()

    return self.normalizing(renaming: &renaming, offset: offset)
  }

  private func normalizing(renaming: inout Dictionary<Symbol, Symbol>, offset: Int = 0) -> Self {
    if let nodes = self.nodes {
      // not a variable
      return Self(symbol: self.symbol, nodes: nodes.map { $0.normalizing(renaming:&renaming) })
    }

    if let symbol = renaming[self.symbol] {
      // variable symbol was allready encountered
      return Self(variable:symbol)
    }

    // variable symbol is unknown so far
    let (string, _) = self.symbolStringType
    let symbol = Self.symbolize(string:"\(string)_\(renaming.count+offset)", type:.variable)
    renaming[self.symbol] = symbol
    return Self(variable:symbol)

  }



}
