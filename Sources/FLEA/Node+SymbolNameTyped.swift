//  Copyright © 2017 Alexander Maringele. All rights reserved.

/* This file contains extensions for protocol `Node`
 to implement protocol `SymbolNameTyped` when
 - Node.Symbol is `TypedName` (almost deprecated) or
 - Node is `SymbolTabulating`, i.e. uses a symbol table (preferred)
 */

/// default implementations for SymbolNameTyped
extension Node where Symbol: TypedName {
    var symbolNameType: (String, Tptp.SymbolType) {
        return (symbol.name, symbol.type)
    }

    static func symbolize(name: String, type: Tptp.SymbolType) -> Symbol {
        return Symbol(name, type)
    }
}

/// default implementations for SymbolNameTyped
extension Node where Self: SymbolTabulating,
    Symbol == Self.Symbols.Symbol, Self.Symbols.Key == String {
    var symbolNameType: (String, Tptp.SymbolType) {
        return Self.symbols[self.symbol] ?? ("\(symbol)", .undefined)
    }

    static func symbolize(name: String, type: Tptp.SymbolType) -> Symbol {
        return symbols.insert(name, type)
    }
}
