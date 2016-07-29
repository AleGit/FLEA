/// Make strings symbolable
extension String : Symbolable {
  static var empty : String { return "" }

  var string : String { return self }
  var type: Tptp.SymbolType {
    switch self {
      case "!":
        return .universal
      case "?":
        return .existential
      case "~":
        return .negation
      case "|":
        return .disjunction
      case "&":
        return .conjunction
      case "=>":
        return .implication
      case "=":
        return .equation
      case "!=":
        return .inequation

      default:
        return .undefined
    }
  }
}

extension String {
  init(of node:TreeNodeRef) {
    let s = node.symbol ?? "n/a"
    // TODO: insert symbol into symbol table
    self.init(s,.undefined)
  }

  init(_ string:String, _ type: Tptp.SymbolType) {
    self = string
  }
}
