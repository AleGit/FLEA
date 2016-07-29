protocol SymbolTable {
  associatedtype Symbol : Symbolable

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Symbol
  subscript(symbol:Symbol) -> String? { get }
}

typealias StringType = (String, Tptp.SymbolType)
struct IntSymbolTable : SymbolTable {
  var symbols = [String : Int]()
  var strings = [Int : StringType] ()

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Int {
    if let symbol = symbols[string] {
      // symbol is allready in the table
      return symbol
    }

    // if (.universal.rawValue <= type.rawValue)
    // && (type.rawValue <= .inequation.rawValue) {
    //   return type.rawValue
    // }

    switch type {
      case .universal, .existential,
      .negation, .disjunction, .conjunction, .implication,
      .equation, .inequation:
      symbols[string] = type.rawValue
      strings[type.rawValue] = (string,type)

      return type.rawValue

      default:
        let value = (symbols.count << 8) // * 256
        + type.rawValue // encode type in value

        symbols[string] = value
        strings[value] = (string,type)

        return value


    }
  }

  subscript(value:Int) -> String? {
    guard 0 <= value && value < strings.count else {
      return nil
    }
    return strings[value]?.0
  }
}

private var globalIntSymbolTable = IntSymbolTable()

extension Int : Symbolable {

  var string : String {
    return globalIntSymbolTable[self] ?? "n/a"

  }

  /// the type is encoded into the value
  /// as the remainder after division by 256
  var type : Tptp.SymbolType {
    return Tptp.SymbolType(rawValue:self % (1 << 8)) ?? .undefined
  }
}
extension Int {
  init(of node:TreeNodeRef) {
    guard let string = node.symbol else {
      self.init("n/a",.undefined)
      return
    }
    self.init(string, .undefined)
  }

  init(_ string:String, _ type: Tptp.SymbolType) {
    self = globalIntSymbolTable.insert(string,type)
  }


}
