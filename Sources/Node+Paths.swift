extension Node where Self:SymbolStringTyped {
  var joker: SymHop<Symbol> {
    return .symbol(Self.symbolize(string:Tptp.wildcard, type:.variable))
  }

  /// Prefix paths from root to leaves.
  /// f(x,g(a,y)) -> { f.1.*, f.2.g.1.a, f.2.g.2.* }
  /// g(f(x,y),b) -> { g.1.f.1.*, g.1.f.2.*, g.2.b}
  var leafPaths: [[SymHop<Symbol>]] {
    guard let nodes = self.nodes else {
      return [[self.joker]]
    }
    guard nodes.count > 0 else {
      return [[.symbol(self.symbol)]]
    }

    let sym = SymHop.symbol(self.symbol)

    var ps = [[SymHop<Symbol>]]()
    for (i, node) in nodes.enumerated() {
      let hop: SymHop<Symbol> = SymHop.hop(i)
      for path in node.leafPaths {
        ps.append([sym, hop] + path)
      }
    }
    return ps
  }

}

extension Node where Symbol == Int, Self:SymbolStringTyped {
  /// Prefix paths from root to leaves.
  /// f(x,g(a,y)) -> { f.1.*, f.2.g.1.a, f.2.g.2.* }
  /// g(f(x,y),b) -> { g.1.f.1.*, g.1.f.2.*, g.2.b}
  var leafPaths: [[Int]] {
    guard let nodes = self.nodes else {
      return [[self.joker]]
    }
    guard nodes.count > 0 else {
      return [[self.symbol]]
    }

    var ps = [[Int]]()
    for (hop, node) in nodes.enumerated() {
      for path in node.leafPaths {
        ps.append([self.symbol, hop] + path)
      }
    }
    return ps
  }

  var joker: Symbol {
    return -1
  }


  var leafPathsPair: ([[Int]], [[Int]]) {
    let paths = leafPaths

    let negated: [[Int]]
    let (_, type) = self.symbolStringType

    switch type {

      case .negation:
        assert(self.nodes?.count == 1)
        negated = paths.map { Array($0.suffix(from:2)) }

      case .equation:
        let symbol = Self.symbolize(string:"!=", type:.inequation)
        negated = paths.map { [symbol] + $0.suffix(from:1) }

      case .inequation:
        let symbol = Self.symbolize(string:"=", type:.equation)
        negated = leafPaths.map { [symbol] + $0.suffix(from:1)}

      case .predicate:
        let symbol = Self.symbolize(string:"~", type:.negation)
        negated = paths.map { [symbol, 0] + $0 }

      default:
        Syslog.error { "\(self) with root type \(type) cannot be negated."}
        assert(false)
        negated = [[Int]]()
    }

    Syslog.debug { "\(self), \(paths), \(negated)" }

    return (paths, negated)

  }

  var preordering: [Int] {
    guard let nodes = self.nodes else {
      // a variable leaf
      return [Self.symbolize(string:Tptp.wildcard, type:.variable)]
    }
    guard nodes.count > 0 else {
      // a constant (function) leaf
      return [self.symbol]
    }

    // an intermediate node
    return nodes.reduce([self.symbol]) { $0 + $1.preordering }

  }
}



extension Node where Self:SymbolStringTyped {
  /// The list of symbols in the node tree in depth-first traversal.
  var preordering: [Symbol] {
    guard let nodes = self.nodes else {
      // a variable leaf
      return [Self.symbolize(string:Tptp.wildcard, type:.variable)]
    }
    guard nodes.count > 0 else {
      // a constant (function) leaf
      return [self.symbol]
    }

    // an intermediate node
    return nodes.reduce([self.symbol]) { $0 + $1.preordering }

  }
}
