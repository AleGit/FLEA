/// A sharing node is a specialized node where
/// a collection of all created nodes is held.
/// Unique instances of nodes are shared between (sub)trees.
/// Sharing is suitable for immutable reference types.

protocol SharingNode : class, Node {
  /// strong references to all nodes
  static var allNodes : Set<Self> { get set }
}

extension SharingNode {
  /// By default sharing nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    if let index = allNodes.index(of:node) {
      return allNodes[index]
    }
    else {
      allNodes.insert(node)
      return node
    }
  }
}

/// A smarter sharing node.
protocol SmartNode : class, Node {
  /// weak references to all nodes
  static var allNodes : WeakSet<Self> { get set }
}

extension SmartNode {
  /// By default smart nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    return allNodes.insert(newElement:node)
  }
}
