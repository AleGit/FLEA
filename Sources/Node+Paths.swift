extension Node where Symbol : Symbolable {
  /// Prefix paths from root to leaves.
  /// f(x,g(a,y)) -> { f.1.*, f.2.g.1.a, f.2.g.2.* }
  /// g(f(x,y),b) -> { g.1.f.1.*, g.1.f.2.*, g.2.b}
  var leafPaths : [[SymHop<Symbol>]] {
    guard let nodes = self.nodes else {
      return [[.symbol(Symbol("*",.variable))]]
    }
    guard nodes.count > 0 else {
      return [[.symbol(self.symbol)]]
    }

    let sym = SymHop.symbol(self.symbol)

    var ps = [[SymHop<Symbol>]]()
    for (i,node) in nodes.enumerated() {
      let hop : SymHop<Symbol> = SymHop.hop(i)
      for path in node.leafPaths {
        ps.append([sym,hop] + path)
      }
    }
    return ps
  }
}

extension Node where Symbol == Int {
  /// Prefix paths from root to leaves.
  /// f(x,g(a,y)) -> { f.1.*, f.2.g.1.a, f.2.g.2.* }
  /// g(f(x,y),b) -> { g.1.f.1.*, g.1.f.2.*, g.2.b}
  var leafPaths : [[Int]] {
    guard let nodes = self.nodes else {
      return [[Symbol("*",.variable)]]
    }
    guard nodes.count > 0 else {
      return [[self.symbol]]
    }

    var ps = [[Int]]()
    for (hop,node) in nodes.enumerated() {
      for path in node.leafPaths {
        ps.append([self.symbol,hop] + path)
      }
    }
    return ps
  }
}

extension Node where Symbol : Symbolable {
  /// The list of symbols in the node tree in depth-first traversal.
  var preordering : [Symbol] {
    guard let nodes = self.nodes else {
      // a variable leaf
      return [Symbol("*",.variable)]
    }
    guard nodes.count > 0 else {
      // a constant (function) leaf
      return [self.symbol]
    }

    // an intermediate node
    return nodes.reduce([self.symbol]) { $0 + $1.preordering }

  }
}
