/// Symbolable (node) types can be instantiated with strings.
protocol Symbolable {

  var string : String { get }
  var type : Tptp.SymbolType { get }

  init(_ string: String, _ type: Tptp.SymbolType)
}

///
protocol SymbolTable {
  associatedtype Symbol : Hashable

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Symbol
  func extract(_ symbol:Symbol) -> (String,Tptp.SymbolType)?
  subscript(symbol:Symbol) -> String? { get }
}

protocol SymbolTableUser {
  associatedtype Symbols : SymbolTable
  static var symbols : Symbols { get set }
}

protocol GenericInteger : Integer {
  init(_ value:Int)
}

extension UInt64 : GenericInteger {}
extension UInt32 : GenericInteger {}
// extension UInt16 : GenericInteger {}
// extension UInt8 : GenericInteger {}
extension UInt : GenericInteger {}
extension Int64 : GenericInteger {}
extension Int32 : GenericInteger {}
// extension Int16 : GenericInteger {}
// extension Int8 : GenericInteger {}
extension Int : GenericInteger {}

typealias StringType = (String, Tptp.SymbolType)

struct IntegerSymbolTable<I:GenericInteger> : SymbolTable {
  private var symbols = [String : I]()
  private var strings = [I : StringType] ()

  func extract(_ symbol:I) -> StringType?  {
    return strings[symbol]
  }

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
