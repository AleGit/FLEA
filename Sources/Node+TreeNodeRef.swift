import CTptpParsing

extension Symbolable {
  /// Create the symbol for a node in the abstract syntax tree.
  init(of node:TreeNodeRef) {
    assert (node.symbol != nil,"TreeNodeRef.\(node.type) must have a symbol.")
    self = Self(node.symbol ?? "", Tptp.SymbolType(of:node))
  }
}

extension Node where Symbol : Symbolable {
  /// Create a node (tree) from an abstract syntax (sub)tree.
  init(tree:TreeNodeRef) {
    let symbol = Symbol(of:tree)

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
