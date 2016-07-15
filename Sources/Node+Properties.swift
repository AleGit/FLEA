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

  var subnodes: Set<Self> {
    let singleton = Set(arrayLiteral:self)
    guard let nodes = self.nodes where nodes.count > 0 else {
      return singleton
    }

    return singleton.union(nodes.flatMap { $0.subnodes })


  }

  var variables: Set<Self> {
    guard let nodes = self.nodes else { return Set(arrayLiteral:self) }
    return Set(nodes.flatMap { $0.variables })
  }

}
