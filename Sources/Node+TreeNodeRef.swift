import CTptpParsing


extension Node where Self:SymbolStringTyped {
  /// symbol string types can be easily initilized with a tree node reference
  init(tree:TreeNodeRef) {
    let type = Tptp.SymbolType(of:tree)

    let symbol = Self.symbolize(string:tree.symbol ?? "n/a", type:type)

    switch tree.type {
    case PRLC_VARIABLE:
      assert (tree.child == nil)
      assert (type == .variable)
      
      self.init(variable:symbol)
    default:
      let nodes = tree.children.map { Self(tree:$0) }
      self.init(symbol:symbol, nodes:nodes)
    }
  }
}
