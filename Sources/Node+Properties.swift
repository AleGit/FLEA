extension Node {
  var isVariable: Bool {
    return self.nodes == nil
  }

  var isConstant: Bool {
    guard let nodes = self.nodes where nodes.count == 0 else {
      return false
    }
    return true
  }
}

extension Node {
  var defaultSubnodes: Set<Self> {
    let singleton = Set(arrayLiteral:self)
    guard let nodes = self.nodes where nodes.count > 0 else {
      return singleton
    }

    return singleton.union(nodes.flatMap { $0.subnodes })
  }

  var defaultVariables: Set<Self> {
    guard let nodes = self.nodes else { return Set(arrayLiteral:self) }
    return Set(nodes.flatMap { $0.variables })
  }
}

extension Node {

  var variables: Set<Self> {
    return defaultVariables
  }

  var subnodes: Set<Self> {
    return defaultSubnodes
  }
}
