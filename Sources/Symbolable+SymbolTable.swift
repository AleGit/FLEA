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
  1. Rename `SymbolStringTyped` to ?
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
  associatedtype Key : Hashable     // usually the symbol as parsed, i.e. a string
  associatedtype Symbol : Hashable  // usually a small structure, e.g. an integer

  mutating func insert(_ key: Key, _ type: Tptp.SymbolType) -> Symbol
  mutating func remove(_ key: Key) -> (Symbol, Tptp.SymbolType)?

  subscript(symbol: Symbol) -> (Key, Tptp.SymbolType)? { get }

  var isEquational: Bool { get }

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
  typealias Key = String
  typealias Symbol = I

  private(set) var isEquational: Bool = false

  private var symbols = [String: I]()
  private var strings = [I: StringType] ()

  // mutating func insert(_ key: Key, _ type:Tptp.SymbolType) -> Symbol
  mutating func insert(_ string: Key, _ type: Tptp.SymbolType) -> Symbol {
    if let symbol = symbols[string] {
      // the symbol is allready in the table, check for consitentcy

      guard let (s, t) = strings[symbol], s == string, type == t else {
        Syslog.error { "\nSymbol '\(symbol)' (\(string),\(type)) <⚡️> \(strings[symbol]))\n" }
        return symbol
      }

      return symbol
    }

    switch type {
      case .equation, .inequation:
      isEquational = true
      default:
      break
    }

    let ivalue: I = I(1+symbols.count) * (type == .variable ? -1 : 1)

    symbols[string] = ivalue
    strings[ivalue] = (string, type)

    return ivalue
  }

  subscript(value: I) -> StringType? {
    return strings[value]
  }

  subscript(value: Key) -> (Symbol, Tptp.SymbolType)? {
    guard let symbol = symbols[value] else {
      return nil
    }
    guard let (_, type) = strings[symbol] else {
      return (symbol, .undefined)
    }
    return (symbol, type)
  }

  mutating func remove(_ string: Key) -> (Symbol, Tptp.SymbolType)? {
    guard let (symbol, type) = self[string] else {
      return nil
    }

    symbols[string] = nil
    strings[symbol] = nil

    return (symbol, type)

  }

  mutating func clear() {
    symbols.removeAll()
    strings.removeAll()
  }
}

/// A string symbol table that maps (string,type) to the same string symbol:
/// Only the symbol type needs to be stored.
struct StringStringTable: SymbolTable {
  typealias Key = String
  typealias Symbol = String

  private(set) var isEquational: Bool = false
  private var types = Dictionary<String, Tptp.SymbolType>() // [String: Tptp.SymbolType]() // won't work

  // mutating func insert(_ key: Key, _ type:Tptp.SymbolType) -> Symbol
  mutating func insert(_ string: Key, _ type: Tptp.SymbolType) -> Symbol {

    if let t = types[string] {
      assert(t==type, "\(string), \(t) != \(type)")
    } else {
      types[string] = type
    }

    switch type {
      case .equation, .inequation:
      isEquational = true
      default:
      break
    }

    return string
  }

  mutating func remove(_ string: String) -> (String, Tptp.SymbolType)? {
    Syslog.error { "-----" }
    return nil
  }

  subscript(value: String) -> StringType? {
    guard let type = types[value] else { return nil }
    return (value, type)
  }

  mutating func clear() {
    types.removeAll()
  }
}
