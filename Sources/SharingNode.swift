protocol Nodes {
  associatedtype Element : Hashable
  func index(of:Element) -> SetIndex<Element>?
  subscript(positions:SetIndex<Element>) -> Element { get }

}

extension Set : Nodes {

}

protocol SharingNode : Node {
  static var sharedNodes : Set<Self> { get set }
}

extension SharingNode {
  init(symbol:Symbol, nodes:[Self]?) {
    self.init()
    self.symbol = symbol
    self.nodes = nodes
    if let index = Self.sharedNodes.index(of:self) {
      self = Self.sharedNodes[index]
    }
    else {
      Self.sharedNodes.insert(self)
    }
  }
}
