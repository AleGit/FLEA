protocol Node : Hashable {
  associatedtype Symbol : Hashable

  static func share(node:Self) -> Self

  init()

  var symbol : Symbol { get set }
  var nodes : [Self]? { get set }

  func calcHashValue() -> Int
}

extension Node {
  init(symbol:Symbol, nodes:[Self]?) {
    self.init()
    self.symbol = symbol
    self.nodes = nodes
    self = Self.share(node:self)
  }
}

extension Node {
  static func share(node:Self)->Self {
    return node
  }

  func calcHashValue() -> Int {
    guard let nodes = self.nodes else {
      return self.symbol.hashValue
    }
    return nodes.reduce(self.symbol.hashValue) { $0 &+ $1.hashValue }
  }

  var hashValue : Int {
    return calcHashValue()
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
  if lhs === rhs { return true }
  else { return lhs.isEqual(to:rhs) }
}
