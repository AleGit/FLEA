/// Make strings symbolable
extension String : Symbolable {
  static var empty : String { return "" }

  var string : String { return self }
  var type: Tptp.Symbol.Kind {
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
    self = s
  }
}
