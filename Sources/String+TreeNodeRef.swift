import CTptpParsing

extension String {
  init?(treeNode:TreeNodeRef?) {
    guard let c = treeNode?.pointee.symbol, let s = String(validatingUTF8:c) else { return nil }
    self = s
  }
}
