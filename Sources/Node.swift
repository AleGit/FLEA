/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// A tree data structure can be defined recursively as a collection of nodes
/// (starting at a root node), where each node is a data structure consisting
/// of a value, together with a list of references to nodes (the "children"),
/// with the constraints that no reference is duplicated, and none points to the root.
/// <a href="https://en.wikipedia.org/wiki/Tree_(data_structure)">wikipedia</a>
protocol Node : Hashable, CustomStringConvertible {
  associatedtype Symbol : Hashable

  /// The Value of the node.
  var symbol : Symbol { get set }
  /// References to nodes (the "children")
  var nodes : [Self]? { get set }

  /// empty initializer to enable sharing magic
  init()

  /// enables sharing of nodes at multiple positions
  /// in the same or a different tree.
  static func share(node:Self) -> Self
}

extension Node {
  /// By default nodes are not shared between trees,
  /// e.g. three instances of variable `X` in `p(X,f(X,X))`
  /// None-sharing is suitable for value types.
  static func share(node:Self) -> Self {
    return node
  }
}

extension Node {

  /// *Dedicated* initializer for all nodes and sharing nodes types.
  /// This enables automatic sharing for all sharing node classes.
  init(symbol:Symbol, nodes:[Self]?) {
    self.init()                   // self must be initialized ...
    self.symbol = symbol
    self.nodes = nodes
    self = Self.share(node:self)  // ... before it can be used
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

// MARK: CustomStringConvertible

extension Node {
  /// implementations of Node will call this
  var description : String { return defaultDescription }

  /// possible usage: lazy var description = defaultDescritpion
  var defaultDescription : String {
    let s = "\(self.symbol)"
    guard let nodes = self.nodes?.map( { $0.defaultDescription })
    else {
      return s
    }
    let tuple = nodes.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}

extension Node where Symbol == Int {
  var debugDescription : String {
    let s = self.symbol < 256 ?
    "\(self.symbol.string)-\(self.symbol.type)" :
    "\(self.symbol / 256)-\(self.symbol.string)-\(self.symbol.type)"
    guard let nodes = self.nodes?.map({$0.debugDescription})
    where nodes.count > 0
    else {
      return s
    }
    let tuple = nodes.map{ "\($0.debugDescription)" }.joined(separator:",")
    return "\(s)(\(tuple))"
  }
}
