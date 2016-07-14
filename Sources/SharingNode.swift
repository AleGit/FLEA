protocol SharingNode : Node {
  static var sharedNodes : Set<Self> { get set }
}

extension SharingNode {
  static func share (node:Self) -> Self {
    if let index = sharedNodes.index(of:node) {
      return sharedNodes[index]
    }
    else {
      sharedNodes.insert(node)
      return node
    }
  }
}
