protocol SymbolTable {
  associatedtype Symbol : Hashable

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Symbol
  subscript(symbol:Symbol) -> String? { get }
}

protocol HasSymbolTable {
  associatedtype Symbols : SymbolTable
  static var symbols : Symbols { get set }
}

protocol GenericInteger : Integer {
  init(_ value:Int)
}

extension UInt32 : GenericInteger {}
extension Int : GenericInteger {}

typealias StringType = (String, Tptp.SymbolType)

struct IntegerSymbolTable<I:GenericInteger> : SymbolTable {
  var symbols = [String : I]()
  var strings = [I : StringType] ()

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> I {
    if let symbol = symbols[string] {
      // symbol is allready in the table
      return symbol
    }

    var value = type.rawValue

    switch type {
      case .universal, .existential,
      .negation, .disjunction, .conjunction, .implication,
      .equation, .inequation:
      break

      default:
        value += (1+symbols.count) << 8 // *256
    }

    let ivalue : I = I(value)

    symbols[string] = ivalue
    strings[ivalue] = (string,type)

    return ivalue
  }

  subscript(value:I) -> String? {
    return strings[value]?.0
  }
}
