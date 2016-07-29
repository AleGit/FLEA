protocol SymbolTable {
  associatedtype Symbol : Symbolable

  mutating func insert(_ string: String, _ type:Tptp.Symbol.Kind) -> Symbol
  subscript(symbol:Symbol) -> String? { get }
}

struct IntSymbolTable : SymbolTable {
  var symbols = [String : Int]()
  var strings = [Int:(String,Tptp.Symbol.Kind]()

  mutating func insert(_ string: String, _ type:Tptp.Symbol.Kind) -> Int {
    if let symbol = symbols[string] {
      // symbol is allready in the table
      return symbol
    }

    // symbol i

    switch type {
      case .universal:
        fall
      case .variable:

        default:
          return type.
    }

    let count = strings.count
    strings.append(string)
    symbols[string] = count
    return count
  }

  subscript(value:Int) -> String? {
    guard 0 <= value && value < strings.count else {
      return nil
    }
    return strings[value]
  }
}

var intSymbolTable : IntSymbolTable = {
  var table = IntSymbolTable()
  return table
}()

extension Int : Symbolable {
  static var empty : Int { return 0 }

  var string : String {

    return "x/a"

  }
  var type : Tptp.Symbol.Kind {
    return .undefined
  }

}

extension Int {
  init(of node:TreeNodeRef) {
    guard let _ = node.symbol else {
      self = 0
      return
    }
    self = 1
  }


}
