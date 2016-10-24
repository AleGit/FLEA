//  Copyright © 2016 Alexander Maringele. All rights reserved.

/* This file contains extensions for protocol `Node`
  to implement protocol `SymbolStringTyped` when
  - Node.Symbol is `StringSymbolable` (almost deprecated) or
  - Node is `SymbolTabulating`, i.e. uses a symbol table (preferred)
  */


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


