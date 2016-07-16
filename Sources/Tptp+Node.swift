import CTptpParsing

struct Tptp {

  final class Node : FLEA.SharingNode {

    static var sharedNodes = Set<Tptp.Node>()

    var symbol = Tptp.Symbol.Undefined
    var nodes : [Tptp.Node]? = nil

    lazy var hashValue : Int = self.calcHashValue()
    lazy var description : String = self.tptpDescription
  }
}

extension Node where Symbol == String {
  init(tree:TreeNodeRef) {
    let symbol = tree.symbol ?? "n/a"

    switch tree.type {
    case PRLC_VARIABLE, PRLC_NAME, PRLC_ROLE:
      self.init(symbol:symbol, nodes:nil)
    default:
      let nodes = tree.children.map { Self(tree:$0) }
      self.init(symbol:symbol, nodes:nodes)
    }
  }
}

extension Node where Symbol == Tptp.Symbol {
  init(tree:TreeNodeRef) {
    let symbol = Tptp.Symbol(type:tree.type, symbol:tree.symbol ?? "n/a")

    switch tree.type {
    case PRLC_VARIABLE, PRLC_NAME, PRLC_ROLE:
      self.init(symbol:symbol, nodes:nil)
    default:
      let nodes = tree.children.map { Self(tree:$0) }
      self.init(symbol:symbol, nodes:nodes)
    }
  }
}
