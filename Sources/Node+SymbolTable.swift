protocol SymbolTable {
  associatedtype Symbol : Hashable

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Symbol
  subscript(symbol:Symbol) -> String? { get }
}

protocol HasSymbolTable {
  associatedtype Symbols : SymbolTable
  static var symbols : Symbols { get set }
  // associatedtype Symbol : Hashable
  //
  // static func insert(string:String, type:Tptp.SymbolType) -> Symbol
  // static func extract(symbol:Symbol) -> (String,Tptp.SymbolType)
}

extension Node where Self:HasSymbolTable, Symbol == Self.Symbols.Symbol {
  init(v:String) {
    let s = Self.symbols.insert(v, .variable)
    self.init(variable:s)
  }

  init(c:String) {
    let s = Self.symbols.insert(c, .function)
    self.init(constant:s)
  }

  init(f:String, _ nodes:[Self]?) {
    let s = Self.symbols.insert(f, .function)
    guard let nodes = nodes else {
      self.init(v:f)
      return
    }
    self.init(symbol:s, nodes:nodes)
  }

  init(p:String, _ nodes:[Self]?) {
    let s = Self.symbols.insert(p, .predicate)
    guard let nodes = nodes else {
      self.init(v:p)
      return
    }
    self.init(symbol:s, nodes:nodes)
  }
}

extension Node where Self:HasSymbolTable, Symbol == Self.Symbols.Symbol {

  /// possible usage: lazy var description = defaultDescritpion
  var defaultDescription : String {
    guard let s = Self.symbols[self.symbol] else { return "n/a" }
    guard let nodes = self.nodes?.map( { $0.defaultDescription }), nodes.count > 0
    else {
      return s
    }
    let tuple = nodes.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}
