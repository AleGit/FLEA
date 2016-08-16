/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

extension Node {
  /// Simple calculation for a consistent hash value,
  /// (i.e. equal nodes have an eqqul hash value)
  /// *Complexity*: O(n)
  /// causes too many collisions
  var simpleHashValue : Int {
    guard let nodes = self.nodes else {
      return self.symbol.hashValue
    }
    return nodes.reduce(self.symbol.hashValue) { ($0 &* 2) &+ $1.hashValue }
  }

  /// Default calculation for a consistent hash value,
  /// (i.e. equal nodes have an eqqul hash value)
  /// *Complexity*: O(n)
  /// significant less collisions than simpleHashValue
  /// TODO: find reference for this idea
  /// e.g. http://stackoverflow.com/questions/1988665/hashing-a-tree-structure
  var defaultHashValue: Int {
    guard let nodes = self.nodes else {
      return self.symbol.hashValue
    }
    return nodes.reduce(5381 &+ self.symbol.hashValue) {
      // ($0 << 5) &+ $0 &+ $1.hashValue
      ($0 << 4) &+ $0 &+ $1.hashValue // less collisions than with $0 << 5
    }
  }
  
  // adopting types could cache the hash value 
  /* lazy var hashValue = defaultHashValue */

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

    guard let lnodes = self.nodes, let rnodes = other.nodes else {
      print(self,self)
      return false }

    return lnodes == rnodes
  }
}

/// Check if two nodes are equal
func ==<N:Node>(lhs:N, rhs:N) -> Bool {
  return lhs.isEqual(to:rhs)
}

/// Speed up equality check for objects.
func ==<N:Node>(lhs:N, rhs:N) -> Bool 
where N:AnyObject {
  if lhs === rhs { return true }
  else { return lhs.isEqual(to:rhs) }
}
