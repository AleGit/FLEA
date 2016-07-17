
extension Node {
  /// Default calculation for a consistent hash value,
  /// (i.e. equal nodes have an eqqul hash value)
  /// O(n)
  var defaultHashValue : Int {
    guard let nodes = self.nodes else {
      return self.symbol.hashValue
    }
    return nodes.reduce(self.symbol.hashValue) { ($0 &* 2) &+ $1.hashValue }
  }

  /// Default hashValue for all Nodes without own implementation.
  var hashValue : Int {
    return defaultHashValue
  }
}

extension Node {
  /// A node is equal to an other noded
  /// - if their symbols are equal
  /// - if their children are equal
  func isEqual(to other:Self) -> Bool {
    guard self.symbol == other.symbol else { return false }
    if self.nodes == nil && other.nodes == nil { return true }

    guard let lnodes = self.nodes, let rnodes = other.nodes else { return false }

    return lnodes == rnodes
  }
}

/// Check if two nodes are equal
func ==<N:Node>(lhs:N, rhs:N) -> Bool {
  return lhs.isEqual(to:rhs)
}

/// Speed up equality check for objects.
func ==<N:Node where N:AnyObject>(lhs:N, rhs:N) -> Bool {
  if lhs === rhs { return true }
  else { return lhs.isEqual(to:rhs) }
}
