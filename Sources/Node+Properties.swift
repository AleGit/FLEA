/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

extension Node {
  var isVariable: Bool {
    return self.nodes == nil
  }

  var isConstant: Bool {
    guard let nodes = self.nodes, nodes.count == 0 else {
      return false
    }
    return true
  }
}

extension Node {
  var defaultSubnodes: Set<Self> {
    let singleton = Set(arrayLiteral:self)
    guard let nodes = self.nodes, nodes.count > 0 else {
      return singleton
    }

    return singleton.union(nodes.flatMap { $0.subnodes })
  }

  var defaultVariables: Set<Self> {
    guard let nodes = self.nodes else {
      return Set(arrayLiteral:self)
    }
    return Set(nodes.flatMap { $0.variables })
  }

  func isSubnode(of s: Self) -> Bool {
    return s.defaultSubnodes.contains(self)
  }
}

extension Node {
  var subnodes: Set<Self> {
    return defaultSubnodes
  }

  var variables: Set<Self> {
    return defaultVariables
  }
}
