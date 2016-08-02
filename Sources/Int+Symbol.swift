typealias StringType = (String, Tptp.SymbolType)

struct IntSymbolTable : SymbolTable {
  var symbols = [String : Int]()
  var strings = [Int : StringType] ()

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Int {
    if let symbol = symbols[string] {
      // symbol is allready in the table
      return symbol
    }

    var value : Int = type.rawValue

    switch type {
      case .universal, .existential,
      .negation, .disjunction, .conjunction, .implication,
      .equation, .inequation:
      break

      default:
        value += (1+symbols.count) << 8 // *256
    }

    symbols[string] = value
    strings[value] = (string,type)

    return value
  }

  subscript(value:Int) -> String? {
    return strings[value]?.0
  }
}

var globalIntSymbolTable : IntSymbolTable = {
  var table = IntSymbolTable()
  let _ = table.insert("",.undefined)
  return table
}()

extension Int : Symbolable {

  var string : String {
    return globalIntSymbolTable[self] ?? "n/a ?"

  }

  /// the type is encoded into the value
  /// as the remainder after division by 256
  var type : Tptp.SymbolType {
    return Tptp.SymbolType(rawValue:self % (256)) ?? .undefined
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
