
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

  /// enables sharing magic
  static func share(node:Self) -> Self
}

extension Node {
  /// By default nodes are not shared between trees,
  /// e.g. three instances of variable `X` in `p(X,f(X,X))`
  /// This is suitable for value types.
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

/// MARK: convenience initializers to build terms with strings.

extension Node where Symbol:Symbolable {
  init(v:String) {
    self.init(variable:Symbol(v,.variable))
  }

  init(c:String) {
    self.init(constant:Symbol(c,.function))
  }

  init(f:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:f)
      return
    }
    self.init(symbol:Symbol(f,.function), nodes:nodes)
  }

  init(p:String, _ nodes:[Self]?) {
    guard let nodes = nodes else {
      self.init(v:p)
      return
    }
    self.init(symbol:Symbol(p,.predicate), nodes:nodes)
  }
}
