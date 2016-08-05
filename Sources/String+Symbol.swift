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
      case "<=":
        return .reverseimpl
      case "=":
        return .equation
      case "!=":
        return .inequation
      case "<~>":
        return .xor
      case "~|":
        return .nor
      case "~&":
        return .nand
      // case "-->":
      //   return .gentzen

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
  var tptpLiteralType : (String,Tptp.SymbolType) {
    if self.isEmpty {
      return (self,.undefined)
    }

    if self.hasPrefix("@") {
      for (prefix,type) in [
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
        Syslog.warning { "Undefined annotation in \(self)" }
      }

      if self.containsOne([
        "?", "!", "~", "-->",
        "&",  "|",  "=>", "<=>", "=",
        "~&", "~|", "<=", "<~>", "~="
      ]) {
        return (self,.fof)
      }

      return (self, .function)
  }
}
