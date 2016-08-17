import CTptpParsing


extension Node where Self:SymbolStringTyped {
  /// symbol string types can be easily initilized with a tree node reference
  init(tree:TreeNodeRef) {

    let symbol = Self.symbolize(string:tree.symbol ?? "", type:Tptp.SymbolType(of:tree))

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
