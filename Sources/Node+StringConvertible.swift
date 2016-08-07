// MARK: - Node:CustomStringConvertible

extension Node where Symbol : Symbolable {
  var defaultDescription : String {
    return buildDescription(string:self.symbol.string,type:self.symbol.type)
  }
}

extension Node where Self:SymbolTableUser, Self.Symbol == Self.Symbols.Symbol {
  var defaultDescription : String {
    let (string,type) = Self.symbols.extract(self.symbol) ?? ("\(self.symbol)", .undefined)
    return buildDescription(string:string,type:type)
  }
}

extension Node {

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

// MARK: - Node.CustomDebugStringConvertible where Node.Symbol:Symbolable

extension Node where Symbol:Symbolable {
  var debugDescription : String {
    let s = "\(self.symbol)-\(self.symbol.string)-\(self.symbol.type)"

    guard let nodes = self.nodes?.map({$0.debugDescription}), nodes.count > 0
    else {
      return s
    }
    let tuple = nodes.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}

extension Node where Symbol == Tptp.Symbol {
  var debugDescription : String {
    let s = "\(self.symbol.debugDescription)"

    guard let nodes = self.nodes?.map({$0.debugDescription}), nodes.count > 0
    else {
      return s
    }
    let tuple = nodes.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}

extension Node where Self:SymbolTableUser, Self.Symbol == Int, Self.Symbols.Symbol == Int {
var debugDescription : String {

  let number = self.symbol / 256
  let type = Tptp.SymbolType(rawValue: self.symbol % 256 ) ?? .undefined
  let string = Self.symbols[self.symbol] ?? "n/a"

  let s = self.symbol < 256 ?
  "\(string)-\(type)" : "\(number)-\(string)-\(type)"
  guard let nodes = self.nodes?.map({$0.debugDescription}), nodes.count > 0
  else {
    return s
  }
  let tuple = nodes.map{ "\($0.debugDescription)" }.joined(separator:",")
  return "\(s)(\(tuple))"
}
}

extension Node where Self:SymbolTableUser, Symbol == Self.Symbols.Symbol {
  var debugDescription : String {
    return "x"
    // let s = self.symbol < 256 ?
    // "\(self.symbol.string)-\(self.symbol.type)" :
    // "\(self.symbol / 256)-\(self.symbol.string)-\(self.symbol.type)"
    // guard let nodes = self.nodes?.map({$0.debugDescription}), nodes.count > 0
    // else {
    //   return s
    // }
    // let tuple = nodes.map{ "\($0.debugDescription)" }.joined(separator:",")
    // return "\(s)(\(tuple))"
  }
}
