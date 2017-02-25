//  Copyright © 2017 Alexander Maringele. All rights reserved.

/* This file contains extensions for protocol `Node`
 to implement protocol `SymbolNameTyped` when
 - Node.Symbol is `StringSymbolable` (almost deprecated) or
 - Node is `SymbolTabulating`, i.e. uses a symbol table (preferred)
 */

/// default implementations for SymbolNameTyped
extension Node where Symbol: StringSymbolable {
    var symbolNameType: (String, Tptp.SymbolType) {
        return (self.symbol.string, self.symbol.type)
    }

    static func symbolize(name: String, type: Tptp.SymbolType) -> Symbol {
        return Symbol(name, type)
    }
}

/// default implementations for SymbolNameTyped
extension Node where Self: SymbolTabulating,
    Symbol == Self.Symbols.Symbol, Self.Symbols.Key == String {
    var symbolNameType: (String, Tptp.SymbolType) {
        return Self.symbols[self.symbol] ?? ("\(self.symbol)", .undefined)
    }

    static func symbolize(name: String, type: Tptp.SymbolType) -> Symbol {
        return self.symbols.insert(name, type)
    }
}
