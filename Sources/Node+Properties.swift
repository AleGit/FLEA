/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

extension Node {
  var isVariable: Bool {
    return self.nodes == nil
  }

  var isConstant: Bool {
    guard let nodes = self.nodes, nodes.count == 0 else {
      return false
    }
    // self.nodes == nil or nodes.count > 0
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
    return self.defaultSubnodes
  }

  var variables: Set<Self> {
    return self.defaultVariables
  }

  var height: Int {
    return self.dimensions.height
  }

  var width: Int {
    return self.dimensions.width
  }

  var size: Int {
    return self.dimensions.size
  }

  var dimensions: Dimensions {
    Syslog.fail(condition:Syslog.carping) { "use of default dimensions implementation" }
    return defaultProperties
  }
}


/* ****************************************************************************************************** */

extension Node {
  typealias Dimensions = (
    // subnodes: Set<Self>,
    // variables: Set<Self>,
    height: Int,
    width: Int,
    size: Int
  )

  var defaultProperties: Dimensions {
    guard let nodes = self.nodes else {
      return (
        // Set(arrayLiteral: self), // a variable is a subnode
        // Set(arrayLiteral: self), // a variable is a variable
        0, // a variable has height 0
        1, // a variable has width 1
        1  // a variable has size 1
      )
    }

    guard nodes.count > 0 else {
      return (
        // Set(arrayLiteral: self), // a constant is a subnode
        // Set<Self>(), // a constant is not a variable
        0, // a constant has height 0
        1, // a constant has width 1
        1  // a constant has size 1
      )
    }

    let base = (
      // subnodes:Set(arrayLiteral:self), // an inner node is a subnode
      // variables:Set<Self>(), // an inner node is not a variable
      height:0, width:0, size:1
    )


    let collect = nodes.reduce(base) {
      return Self.combine(lhs:$0, rhs:$1.dimensions)
    }

    return (
      // collect.0, // self was allready added to the set of subnodes
      // collect.1, // self is not a member of set of variables
      collect.height + 1, // add one to the maximum height of all subtrees
      collect.width, // the total sum is just the sum of all widths of the subtrees
      collect.size // we've allready added one to the sum of sizes of the subtrees
    )
  }

  private static func combine(lhs: Dimensions, rhs: Dimensions) -> Dimensions {
    return (
      // subnodes:lhs.subnodes.union(rhs.subnodes),
      // variables:lhs.variables.union(rhs.variables),
      height:max(lhs.height, rhs.height),
      width:lhs.width + rhs.width,
      size:lhs.size + rhs.size)
  }
}






