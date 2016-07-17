import CTptpParsing

struct Tptp {

  final class Node : FLEA.SharingNode {

    static var sharedNodes = Set<Tptp.Node>()

    var symbol = Tptp.Symbol("n/a",.Undefined)
    var nodes : [Tptp.Node]? = nil

    lazy var hashValue : Int = self.calcHashValue()
    lazy var description : String = self.tptpDescription
  }
}

extension Node {
  init(tree:TreeNodeRef) {
    self.init(tree:tree, f:Self.register)
  }

  init(tree:TreeNodeRef, f:(symbol:TreeNodeRef) -> Symbol) {
    let symbol = f(symbol:tree)

    switch tree.type {
    case PRLC_VARIABLE:
      self.init(symbol:symbol, nodes:nil)
    default:
      let nodes = tree.children.map { Self(tree:$0) }
      self.init(symbol:symbol, nodes:nodes)
    }
  }
}

extension Node where Symbol == String {
  static func register(symbol:TreeNodeRef) -> String {
    return symbol.symbol ?? "n/a"
  }
}

extension Node where Symbol == Tptp.Symbol {
  static func register(symbol:TreeNodeRef) -> Tptp.Symbol {
    return Tptp.Symbol(symbol:symbol.symbol ?? "n/a", type:symbol.type)
  }
}
