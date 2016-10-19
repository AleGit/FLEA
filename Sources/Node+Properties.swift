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
  var defaultHeight: Int {
    guard let nodes = self.nodes, nodes.count > 0 else {
      return 0
    }

    // 1 + max(n1.height, ..., ni.height, ... nn.height)
    return nodes.reduce(1) { max($0, $1.height)}
  }

  var defaultWidth: Int {
    guard let nodes = self.nodes, nodes.count > 0 else {
      return 1
    }

    // n1.width + ... + ni.width + ... nn.width
    return nodes.reduce(0) { $0 + $1.width }
  }
  var defaultSize: Int {
    guard let nodes = self.nodes, nodes.count > 0 else {
      return 1
    }

    // 1 + n1.size + ... + ni.size + ... nn.size
    return nodes.reduce(1) { $0 + $1.size}
  }
}


extension Node {
  var subnodes: Set<Self> {
    Syslog.fail(condition:Syslog.carping) { "use of default implementation" }
    return defaultSubnodes
  }

  var variables: Set<Self> {
    Syslog.fail(condition:Syslog.carping) { "use of default implementation" }
    return defaultVariables
  }

  var height: Int {
    Syslog.fail(condition:Syslog.carping) { "use of default implementation" }
    return defaultHeight
  }

  var width: Int {
    Syslog.fail(condition:Syslog.carping) { "use of default implementation" }
    return defaultWidth
  }

  var size: Int {
    Syslog.fail(condition:Syslog.carping) { "use of default implementation" }
    return defaultSize
  }
}

