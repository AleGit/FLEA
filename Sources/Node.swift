
/// A tree data structure can be defined recursively as a collection of nodes
/// (starting at a root node), where each node is a data structure consisting
/// of a value, together with a list of references to nodes (the "children"),
/// with the constraints that no reference is duplicated, and none points to the root.
/// <a href="https://en.wikipedia.org/wiki/Tree_(data_structure)">wikipedia</a>
protocol Node : Hashable, CustomStringConvertible, CustomDebugStringConvertible {
  associatedtype Symbol : Hashable

  /// Value of the node
  var symbol : Symbol { get set }
  /// References to nodes (the "children")
  var nodes : [Self]? { get set }

  /// empty initializer to enable sharing magic
  init()

  static func share(node:Self) -> Self
  static func symbol(of node:TreeNodeRef) -> Symbol
}

/// A sharing node is a specialized node where
/// a collection of all created nodes is held.
protocol SharingNode : Node {
  static var allNodes : Set<Self> { get set }
}

/// Node extension with dedicated initializer
extension Node {
}

extension Node {
  /// By default nodes are not shared between trees.
  static func share(node:Self) -> Self {
    return node
  }
}

extension SharingNode {
  /// By default sharing nodes are shared between trees.
  static func share (node:Self) -> Self {
    if let index = allNodes.index(of:node) {
      return allNodes[index]
    }
    else {
      allNodes.insert(node)
      return node
    }
  }
}

extension Node {

  /// *Dedicated* initializer for all nodes and sharing nodes.
  init(symbol:Symbol, nodes:[Self]?) {
    self.init()
    self.symbol = symbol
    self.nodes = nodes
    self = Self.share(node:self)
  }

  /// Conveniance initializer for variables.
  init(variable:Symbol) {
    self.init(symbol:variable, nodes:nil)
  }

  /// Convenience initializer for constants.
  init(constant:Symbol) {
    self.init(symbol:constant, nodes:[Self]())
  }

  /// Convenience initializer for nodes with a sequence of children.
  init<S:Sequence where S.Iterator.Element == Self>(symbol:Symbol, nodes:S?) {
    self.init(symbol:symbol, nodes: nodes?.map ({ $0 }))
  }
}
