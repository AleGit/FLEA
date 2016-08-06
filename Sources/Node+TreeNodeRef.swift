import CTptpParsing

extension Node where Symbol : Symbolable {
  /// Create a node (tree) from an abstract syntax (sub)tree.
  init(tree:TreeNodeRef) {

    let symbol = Symbol(tree.symbol ?? "", Tptp.SymbolType(of:tree))

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

extension Node where Self:HasSymbolTable, Symbol == Self.Symbols.Symbol {
  init(tree:TreeNodeRef) {

    let symbol = Self.symbols.insert(tree.symbol ?? "", Tptp.SymbolType(of:tree))

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
