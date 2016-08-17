/// provide default implementations for Node : SymbolStringTyped
extension Node where Self:StringSymbolTabulating, Symbol == Self.Symbols.Symbol {
  var symbolStringType : (String,Tptp.SymbolType) {
    return Self.symbols[self.symbol] ?? ("\(self.symbol)",.undefined)
  }

  static func symbolize(string:String, type:Tptp.SymbolType) -> Symbol {
    return self.symbols.insert(string, type)
  }
}