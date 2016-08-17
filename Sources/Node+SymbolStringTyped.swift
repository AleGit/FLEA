/// default implementations where Node : SymbolStringTyped
extension Node where Symbol:StringSymbolable {
  var symbolStringType : (String,Tptp.SymbolType) {
    return (self.symbol.string, self.symbol.type)
  }

  static func symbolize(string:String, type:Tptp.SymbolType) -> Symbol {
    return Symbol(string,type)
  }
}

/// provide default implementations for Node : SymbolStringTyped
extension Node where Self:SymbolTabulating, Symbol == Self.Symbols.Symbol, Self.Symbols.Key == String {
  var symbolStringType : (String,Tptp.SymbolType) {
    return Self.symbols[self.symbol] ?? ("\(self.symbol)",.undefined)
  }

  static func symbolize(string:String, type:Tptp.SymbolType) -> Symbol {
    return self.symbols.insert(string, type)
  }
}


