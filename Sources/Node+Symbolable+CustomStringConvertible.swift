/*** This file cannot move to an own nodes module because Node.Symbol:Symbolable. ***/

// MARK: - CustomStringConvertible

extension Node where Symbol : Symbolable {

  var defaultDescription : String {
    let s = self.symbol.string
    guard let nodes = self.nodes?.map({$0.description})
    where nodes.count > 0 else {
      return s
    }
    switch self.symbol.type {
      case .universal, .existential:
        assert(nodes.count > 0)
        let vars = nodes[0..<(nodes.count-1)].joined(separator:",")
        return "\(s)[\(vars)]\(nodes.last!)"

      case .negation:
        assert(nodes.count == 1)
        return "\(s)(\(nodes.first!))"

      case .disjunction, .conjunction:
        assert(nodes.count > 0)
        let tuple = nodes.joined(separator:s)
        return "(\(tuple))"

      case .implication, .reverseimpl,
      .bicondition, .xor, .nand, .nor:
        assert(nodes.count == 2)
        return "(\(nodes.first!)\(s)\(nodes.last!))"

      case .equation, .inequation:
        assert(nodes.count == 2)
        return nodes.joined(separator:s)

      case .file, .fof, .cnf, .include, .name, .role, .annotation,
      .predicate, .function:
        assert (nodes.count > 0)
        let tuple = nodes.joined(separator:",")
        return "\(s)(\(tuple))"
      case .variable:
        assert(false,">>\(s)-\(self.symbol.type)")
        return s
      case .undefined:
        assert(false,"\(s)-\(self.symbol.type)")
        return ">>\(s)-\(self.symbol.type)"
    }
  }
}

// MARK: - CustomDebugStringConvertible

extension Node where Symbol:Symbolable {
  var debugDescription : String {
    let s = "\(self.symbol)-\(self.symbol.string)-\(self.symbol.type)"

    guard let nodes = self.nodes?.map({$0.debugDescription})
    where nodes.count > 0
    else {
      return s
    }
    let tuple = nodes.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}

extension Node where Symbol == Tptp.Symbol {
  var debugDescription : String {
    let s = "\(self.symbol)"

    guard let nodes = self.nodes?.map({$0.debugDescription})
    where nodes.count > 0
    else {
      return s
    }
    let tuple = nodes.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}
