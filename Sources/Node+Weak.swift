
protocol SmartNode : class, Node {

  static var allNodes : WeakCollection<Self> { get set }
}

extension SmartNode {
  /// By default sharing nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    return allNodes.insert(newElement:node)
  }
}
