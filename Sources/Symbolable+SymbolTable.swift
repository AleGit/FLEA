/// Symbol name typed nodes can convert their symbol 
/// to a pair of name and type, and vice versa.
/// - extension Node where Symbol:TypedName, 
///   i.e. the symbol itself does the conversion
/// - extension Node where Self:SymbolTabulating, Symbols.Symbol == Symbol, 
///   i.e. a symbol table does the conversion
/// This unifies code for nodes with name typed symbols and symbol tables.
protocol SymbolNameTyped {
    associatedtype Symbol: Hashable

    var symbolNameType: (String, Tptp.SymbolType) { get }
    static func symbolize(name: String, type: Tptp.SymbolType) -> Symbol
}

/// A typed name is a symbol that contains its symbol name and its symbol type.
protocol TypedName {
    var name: String { get }
    var type: Tptp.SymbolType { get }

    init(_ string: String, _ type: Tptp.SymbolType)
}

/// A symbol table maps symbols to pairs of keys (names) and types, and vice versa.
protocol SymbolTable {
    associatedtype Key: Hashable // usually the symbol as parsed, i.e. a string
    associatedtype Symbol: Hashable // usually a small structure, e.g. an integer

    /// insert a key with type and get the symbol.
    mutating func insert(_ key: Key, _ type: Tptp.SymbolType) -> Symbol
    
    /// remove key and get symbol with type
    mutating func remove(_ key: Key) -> (Symbol, Tptp.SymbolType)?

    /// get key and type of symbol
    subscript(symbol: Symbol) -> (Key, Tptp.SymbolType)? { get }

    var isEquational: Bool { get }
}

/// A symbol table users type holds a symbol table.
protocol SymbolTabulating {
    associatedtype Symbols: SymbolTable
    static var symbols: Symbols { get set }
}

/// Integers that can be initialized with an `Int` value.
protocol GenericInteger: Integer {
    init(_ value: Int)
}

extension UInt64: GenericInteger {}
extension UInt32: GenericInteger {}
// extension UInt16 : GenericInteger {}
// extension UInt8 : GenericInteger {}
extension UInt: GenericInteger {}

extension Int64: GenericInteger {}
extension Int32: GenericInteger {}
// extension Int16 : GenericInteger {}
// extension Int8 : GenericInteger {}
extension Int: GenericInteger {}

/// A string symbol table that maps (string,type) to an integer symbol.
struct IntegerSymbolTable<I: GenericInteger>: SymbolTable {
    typealias Key = String
    typealias Symbol = I

    private(set) var isEquational: Bool = false

    private var symbols = [ Tptp.wildcard : I(-1) ]
    private var names = [ I(-1) : (Tptp.wildcard, Tptp.SymbolType.variable) ]

    // mutating func insert(_ key: Key, _ type:Tptp.SymbolType) -> Symbol
    mutating func insert(_ name: String, _ type: Tptp.SymbolType) -> Symbol {
        if let symbol = symbols[name] {

            // consitency check
            guard let (s, t) = names[symbol], s == name, type == t else {
                Syslog.error { "\nSymbol '\(symbol)' (\(name),\(type)) <⚡️> \(names[symbol]))\n" }
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

        let symbol: I = I(symbols.count)

        symbols[name] = symbol
        names[symbol] = (name, type)

        return symbol
    }

    subscript(symbol: I) -> (String, Tptp.SymbolType)? {
        return names[symbol]
    }

    subscript(name: String) -> (Symbol, Tptp.SymbolType)? {
        guard let symbol = symbols[name] else {
            return nil
        }
        guard let (_, type) = names[symbol] else {
            return (symbol, .undefined)
        }
        return (symbol, type)
    }

    mutating func remove(_ name: String) -> (Symbol, Tptp.SymbolType)? {
        guard let (symbol, type) = self[name] else {
            return nil
        }

        symbols[name] = nil
        names[symbol] = nil

        return (symbol, type)
    }

    mutating func clear() {
        symbols = [ Tptp.wildcard : I(-1) ]
        names = [ I(-1) : (Tptp.wildcard, Tptp.SymbolType.variable) ]
    }
}

/// A string symbol table that maps (string,type) to the same string symbol:
/// Only the symbol type needs to be stored.
struct StringSymbolTable: SymbolTable {
    typealias Key = String
    typealias Symbol = String

    private(set) var isEquational: Bool = false
    private var types = Dictionary<String, Tptp.SymbolType>() // [String: Tptp.SymbolType]() // won't work

    // mutating func insert(_ key: Key, _ type:Tptp.SymbolType) -> Symbol
    mutating func insert(_ string: Key, _ type: Tptp.SymbolType) -> Symbol {

        if let t = types[string] {
            assert(t == type, "\(string), \(t) != \(type)")
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

    subscript(value: String) -> (String, Tptp.SymbolType)? {
        guard let type = types[value] else { return nil }
        return (value, type)
    }

    mutating func clear() {
        types.removeAll()
    }
}
