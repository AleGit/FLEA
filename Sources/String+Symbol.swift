/// String MUST NOT be StringSymbolable because it cannot store the SymbolType reliable.

extension String {

  /// Some strings have a canonical symbol type.
  var symbolType: Tptp.SymbolType {
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
      case "<=>":
        return .bicondition
      // case "-->":
      //   return .gentzen

      default:
        if self.isUppercased(at:self.startIndex) {
          return .variable
        }

        return .undefined // WORKAROUND
    }
  }

  /// String literals to be converted to nodes can be annotated
  /// with the type of its root node to avoid ambiguity.
  var tptpStringLiteralType : (String,Tptp.SymbolType) {
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

      return (self, .function(-1)) // .function(_) or .variable
  }
}
