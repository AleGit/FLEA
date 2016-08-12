/// StringSymbolable (node) types can be instantiated with strings.
protocol StringSymbolable {
  var string : String { get }
  var type : Tptp.SymbolType { get }

  init(_ string: String, _ type: Tptp.SymbolType)
}

/// Symbol tables store mappings from (string,type) pairs to symbols, and vice versa.
protocol StringSymbolTable {
  associatedtype Symbol : Hashable

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Symbol
  subscript(symbol:Symbol) -> StringType? { get }
}

/// A symbol table users type holds a static symbol table.
protocol StringSymbolTabulating {
  associatedtype Symbols : StringSymbolTable
  static var symbols : Symbols { get set }
}

/// A helper protocol to use Iteger as generic constraint.
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

/// A (string,type) pair to be mapped to a symbol
typealias StringType = (String, Tptp.SymbolType)

/// A symbol tabple that maps (string,type) to an integer symbol.
struct IntegerSymbolTable<I:GenericInteger> : StringSymbolTable {
  private var symbols = [String : I]()
  private var strings = [I : StringType] ()

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> I {
    if let symbol = symbols[string] {
      // symbol is allready in the table

      return symbol
    }

    let ivalue : I = I(1+symbols.count)

    symbols[string] = ivalue
    strings[ivalue] = (string,type)

    return ivalue
  }

  subscript(value:I) -> StringType? {
    return strings[value]
  }
}
