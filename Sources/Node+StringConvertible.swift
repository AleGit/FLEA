// MARK: - Node:CustomStringConvertible

extension Node {
  /// implementations of Node will call this
  var description : String { return defaultDescription }

  /// possible usage: lazy var description = defaultDescritpion
  var defaultDescription : String {
    let s = "\(self.symbol)"
    // without reliable symbol type information, everything is a prefix function.
    // empty parenthesis will be ommitted, e.g. for variables, constants, predicates.
    return self.buildDescription(string:s, type:.function)
  }
}

extension Node where Symbol : Symbolable {
  var defaultDescription : String {
    /// Symbolable provides reliable symbol type information
    return buildDescription(string:self.symbol.string,type:self.symbol.type)
  }
}

extension Node where Self:SymbolTableUser, Self.Symbol == Self.Symbols.Symbol {
  var defaultDescription : String {
    let (string,type) = Self.symbols.extract(self.symbol) ?? ("\(self.symbol)", .function)
    /// Symbol tables provide usual reliable type information,
    /// fallback to functional prefix notation.
    return buildDescription(string:string,type:type)
  }
}

extension Node {

  /// Build a description with symbol string and type.
  func buildDescription(string:String,type:Tptp.SymbolType) -> String {
    guard let nodes = self.nodes?.map({$0.description}), nodes.count > 0 else {
      return string
    }
    switch type {
      case .universal, .existential:
        assert(nodes.count > 0)
        let vars = nodes[0..<(nodes.count-1)].joined(separator:",")
        return "\(string)[\(vars)]\(nodes.last!)"

      case .negation:
        assert(nodes.count == 1)
        return "\(string)(\(nodes.first!))"

      case .disjunction, .conjunction:
        assert(nodes.count > 0)
        let tuple = nodes.joined(separator:string)
        return "(\(tuple))"

      case .implication, .reverseimpl,
      .bicondition, .xor, .nand, .nor:
        assert(nodes.count == 2)
        return "(\(nodes.first!)\(string)\(nodes.last!))"

      case .equation, .inequation:
        assert(nodes.count == 2)
        return nodes.joined(separator:string)

      case .file, .fof, .cnf, .include, .name, .role, .annotation,
      .predicate, .function:
        assert (nodes.count > 0)
        let tuple = nodes.joined(separator:",")
        return "\(string)(\(tuple))"
      case .variable:
        assert(false,">>\(string)-\(type)")
        return string
      case .undefined:
        assert(false,"\(string)-\(type)")
        return ">>\(string)-\(type)"
    }
  }
}

// MARK: - Node.CustomDebugStringConvertible

extension Node {
  /// Build a more verbose description in prefix notation.
  func buildDebugDescription(string:String) -> String {
    guard let nodes = self.nodes?.map( { $0.debugDescription }), nodes.count > 0
    else { return string }
    let tuple = nodes.joined(separator:",")
    return "\(string)(\(tuple))"
  }
}

extension Node {
  var debugDescription: String {
    // without reliable string and type information we just use string interpolation
    return buildDebugDescription(string:"\(self.symbol)")
  }
}

extension Node where Symbol:Symbolable {
  var debugDescription : String {
    // with reliable string and type information we use it
    return buildDebugDescription(string:"\(self.symbol)-\(self.symbol.string)-\(self.symbol.type)")
  }
}

extension Node where Symbol == Tptp.Symbol {
  var debugDescription : String {
    return buildDebugDescription(string:"\(self.symbol.debugDescription)")
  }
}

// extension Node where Self:SymbolTableUser, Self.Symbol == Int, Self.Symbols.Symbol == Int {
//   var debugDescription : String {
//
//     let number = self.symbol / 256
//     let type = Tptp.SymbolType(rawValue: self.symbol % 256 ) ?? .undefined
//     let string = Self.symbols[self.symbol] ?? "\(self.symbol)"
//
//     return buildDebugDescription(string:number == 0 ? "\(string)-\(type)" : "\(number)-\(string)-\(type)")
//   }
// }

extension Node where Self:SymbolTableUser, Symbol == Self.Symbols.Symbol {
  var debugDescription : String {
    let (string,type) = Self.symbols.extract(self.symbol) ?? ("\(self.symbol)", .undefined)

    return buildDebugDescription(string:"\(string)-\(type)")
  }
}
