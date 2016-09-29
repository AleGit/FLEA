/*
  ### Tasks: find better names for (some) protocols and typealias
  1. _protocol_ `SymbolStringTyped`, i.e. a type with a symbol
      and a `Self.Symbol` <-> `(String,SymbolType)` conversion,
     default implementations are provided for types that
     - either adopt `SymbolTabulating`
     - or use Self.Symbol : StringSymbolable
  2. _protocol_ `StringSymbolable`, i.e. a _symbol_ (type)
      with a `Self` <-> (String,SymbolType)` conversion.
  3. _typealias_ `StringType = (String,SymbolType)`
  4. _protocol_ `SymbolTable`, i.e. a type
      with a 'Key' -> 'Symbol' mapping. (Key type is usually `String`)
  5. _protocol_ `SymbolTabulating`, i.e. a type that stores symbols
      (strings, types) in a symbol table.

  ### Proposals
  1. Rename `SymbolStringTyped` to
  2. Rename `StringSymbolable` to `StringTyped`,
    since `where Self.Symbol : StringTyped` is nice to read.
  3. Rename `StringType` to `StringTypePair`,
    `StringSymbolType`, `StringSymbolTypePair` for more clarity.
  4.
  5.
*/



/// Symbol string typed nodes can convert symbols to pairs of string and type,
/// and vice versa e.g.
/// - extension Node where Symbol:StringSymbolable {
/// - extension Node where Self:SymbolTabulating, Symbols.Symbol == Symbol
/// This unifies code for nodes with string typed symbols or symbol tables.
protocol SymbolStringTyped {
  associatedtype Symbol : Hashable

  var symbolStringType: StringType { get }
  static func symbolize(string: String, type: Tptp.SymbolType) -> Symbol
  // static var joker: Symbol
}


/// A string symbolable type contains its string representation and its symbol type.
protocol StringSymbolable {
  var string: String { get }
  var type: Tptp.SymbolType { get }

  init(_ string: String, _ type: Tptp.SymbolType)
}

/// A symbol table maps symbols to pairs of string and type, and vice versa.
/// (usually Key == String)
protocol SymbolTable {
  associatedtype Key : Hashable
  associatedtype Symbol : Hashable

  mutating func insert(_ key: Key, _ type: Tptp.SymbolType) -> Symbol
  subscript(symbol: Symbol) -> (Key, Tptp.SymbolType)? { get }
}

/// A symbol table users type holds a symbol table.
protocol SymbolTabulating {
  associatedtype Symbols : SymbolTable
  static var symbols: Symbols { get set }
}

/// Integers that can be initialized with an `Int` value.
protocol GenericInteger: Integer {
  init(_ value: Int)
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

/// A string symbol tabple that maps (string,type) to an integer symbol.
struct StringIntegerTable<I:GenericInteger> : SymbolTable {
  private var symbols = [String : I]()
  private var strings = [I : StringType] ()

  // mutating func insert(_ key: Key, _ type:Tptp.SymbolType) -> Symbol
  mutating func insert(_ string: String, _ type: Tptp.SymbolType) -> I {
    if let symbol = symbols[string] {
      // symbol is allready in the table
      assert(strings[symbol]?.1 == type, "\(strings[symbol]?.1) != \(type) \(string)")

      return symbol
    }

    let ivalue: I = I(1+symbols.count)

    symbols[string] = ivalue
    strings[ivalue] = (string, type)

    return ivalue
  }

  subscript(value: I) -> StringType? {
    return strings[value]
  }
}

/// A string symbol table that maps (string,type) to the same string symbol:
/// Only the symbol type needs to be stored.
struct StringStringTable: SymbolTable {
  // private var types = [String : Tptp.SymbolType]()
  // error: type of expression is ambiguous without more context
  // private var types = [String : Tptp.SymbolType]()
  //                     ^~~~~~~~~~~~~~~~~~~~~~~~~~
  private var types = Dictionary<String, Tptp.SymbolType>()

  // mutating func insert(_ key: Key, _ type:Tptp.SymbolType) -> Symbol
  mutating func insert(_ string: String, _ type: Tptp.SymbolType) -> String {

    if let t = types[string] {
      assert(t==type)
    } else {
      types[string] = type
    }

    return string
  }

  subscript(value: String) -> StringType? {
    guard let type = types[value] else { return nil }
    return (value, type)
  }
}
