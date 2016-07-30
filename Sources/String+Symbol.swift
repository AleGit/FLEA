/// Make strings symbolable
extension String : Symbolable {

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
        if self.isUppercased(at:self.startIndex) {
          return .variable
        }

        return .function
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
