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

extension String {
  var termLiteralType : (String,Tptp.SymbolType) {
    if self.isEmpty {
      return (self,.undefined)
    }

    if self.hasPrefix("@") {
      for (prefix,type) in [
        "@variable " : Tptp.SymbolType.variable,
        "@constant " : Tptp.SymbolType.function,
        "@function " : Tptp.SymbolType.function,
        "@term " : Tptp.SymbolType.function,
        "@predicate " : Tptp.SymbolType.predicate,
        "@cnf " : Tptp.SymbolType.cnf,
        "@fof " : Tptp.SymbolType.fof,
        "@include " : Tptp.SymbolType.include,
        "@file " : Tptp.SymbolType.file
        ] {
          if self.hasPrefix(prefix) {
            let s = self.substring(from:self.range(of:prefix)!.upperBound)
            return (s,type)
          }
        }
      }
      else {
        if self.contains("&") || self.contains("=>") {
          return (self,.fof)
        }
        if self.contains("|") {
          return (self,.cnf)
        }
        if self.contains("=") || self.contains("!=") || self.contains("~") {
          return (self,.predicate)
        }
      }
      return (self, .function)
  }
}
