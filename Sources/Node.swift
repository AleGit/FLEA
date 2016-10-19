/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// A tree data structure can be defined recursively as a collection of nodes
/// (starting at a root node), where each node is a data structure consisting
/// of a value, together with a list of references to nodes (the "children"),
/// with the constraints that no reference is duplicated, and none points to the root.
/// <a href="https://en.wikipedia.org/wiki/Tree_(data_structure)">wikipedia</a>
protocol Node: Hashable,
  CustomStringConvertible, CustomDebugStringConvertible {

  associatedtype Symbol : Hashable

  /// The Value of the node.
  var symbol: Symbol { get set }
  /// References to nodes (the "children")
  var nodes: [Self]? { get set }

  /// every adopting type (even non-sharing) must provide the empty initializer
  init()

  /// enables sharing of nodes at multiple positions within or between trees.
  static func share(node: Self) -> Self


  /// properties of terms
  var height: Int { get }
}

extension Node {
  /// By default nodes are not shared within or between trees,
  /// e.g. four instances of variable `X` in `p(X,f(X,X))` and `q(X)`
  /// None-sharing is suitable for value types.
  static func share(node: Self) -> Self {
    return node
  }
}

extension Node {

  /// *Dedicated* initializer for all non-sharing and sharing nodes types.
  init(symbol: Symbol, nodes: [Self]?) {
    self.init()                   // self must be initialized ...
    self.symbol = symbol
    self.nodes = nodes
    self = Self.share(node:self)  // ... before it can be used
  }

  /// Conveniance initializer for variables.
  init(variable: Symbol) {
    self.init(symbol:variable, nodes:nil)
  }

  /// Convenience initializer for constants.
  init(constant: Symbol) {
    self.init(symbol:constant, nodes:[Self]())
  }

  /// Convenience initializer for nodes with a sequence of children.
  init<S: Sequence>(symbol: Symbol, nodes: S?)
  where S.Iterator.Element == Self {
    self.init(symbol:symbol, nodes: nodes?.map ({ $0 }))
  }
}

// MARK: Conversion between `Node<S:Symbol>` implemenations with matching symbol types.

extension Node {
    init<N: Node>(_ other: N)
    where N.Symbol == Symbol {    // similar to Int(3.5)

        // no conversion between same types
        if let t = other as? Self {
            self = t
        } else if let nodes = other.nodes {
            self = Self(symbol: other.symbol, nodes: nodes.map { Self($0) })
        } else {
            self = Self(variable: other.symbol)
        }
    }
}
