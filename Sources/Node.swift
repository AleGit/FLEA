protocol Node : Hashable {
  associatedtype Symbol : Hashable
  var symbol : Symbol { get set }
  var nodes : [Self]? { get set }

  init()
}

extension Node {
  init(symbol:Symbol, nodes:[Self]?) {
    self.init()
    self.symbol = symbol
    self.nodes = nodes
  }
}

extension Node {
  var hashValue : Int {
    guard let nodes = self.nodes else {
      return self.symbol.hashValue
    }
    return nodes.reduce(self.symbol.hashValue) { $0 &+ $1.hashValue }
  }
}



extension Node {
  func isEqual(to other:Self) -> Bool {
    guard self.symbol == other.symbol else { return false }
    if self.nodes == nil && other.nodes == nil { return true }

    guard let lnodes = self.nodes, let rnodes = other.nodes else { return false }

    return lnodes == rnodes
  }
}

func ==<N:Node>(lhs:N, rhs:N) -> Bool {
  return lhs.isEqual(to:rhs)
}

func ==<N:Node where N:AnyObject>(lhs:N, rhs:N) -> Bool {
  print("\(lhs.dynamicType) \(rhs.dynamicType)")
  if lhs === rhs { return true }
  else { return lhs.isEqual(to:rhs) }
}
