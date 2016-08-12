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
  subscript(symbol:Symbol) -> StringSymbolType? { get }
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
typealias StringSymbolType = (String, Tptp.SymbolType)

/// A symbol tabple that maps (string,type) to an integer symbol.
struct StringIntegerTable<I:GenericInteger> : StringSymbolTable {
  private var symbols = [String : I]()
  private var strings = [I : StringSymbolType] ()

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> I {
    if let symbol = symbols[string] {
      // symbol is allready in the table
      assert(strings[symbol]?.1 == type, "\(strings[symbol]?.1) != \(type)")

      return symbol
    }

    let ivalue : I = I(1+symbols.count)

    symbols[string] = ivalue
    strings[ivalue] = (string,type)

    return ivalue
  }

  subscript(value:I) -> StringSymbolType? {
    return strings[value]
  }
}

struct StringStringTable : StringSymbolTable {
  // private var types = [String : Tptp.SymbolType]()
  // error: type of expression is ambiguous without more context
  // private var types = [String : Tptp.SymbolType]()
  //                     ^~~~~~~~~~~~~~~~~~~~~~~~~~
  private var types = Dictionary<String,Tptp.SymbolType>()
  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> String {

    if let t = types[string] {
      assert(t==type)
    }
    else {
      types[string] = type
    }

    return string
  }

  subscript(value:String) -> StringSymbolType? {
    guard let type = types[value] else { return nil }
    return (value,type)
  }
}
