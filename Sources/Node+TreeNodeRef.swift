import CTptpParsing

extension Node {
  init(tree:TreeNodeRef) {
    self.init(tree:tree, symbol: Self.symbol)
  }

  init(tree:TreeNodeRef, symbol: (of:TreeNodeRef) -> Symbol) {
    let symbol = symbol(of:tree)

    switch tree.type {
    case PRLC_VARIABLE:
      assert (tree.child == nil)
      self.init(variable:symbol)
    default:
      let nodes = tree.children.map { Self(tree:$0) }
      self.init(symbol:symbol, nodes:nodes)
    }
  }
}

extension Node where Symbol == String {
  static func symbol(of tree:TreeNodeRef) -> String {
    return tree.symbol ?? "n/a"
  }
}

extension Node where Symbol == Tptp.Symbol {
  static func symbol(of tree:TreeNodeRef) -> Tptp.Symbol {
    return Tptp.Symbol(symbol:tree.symbol ?? "n/a", type:tree.type)
  }
}