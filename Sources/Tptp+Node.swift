import CTptpParsing

struct Tptp {

  final class Node : FLEA.SharingNode {

    static var sharedNodes = Set<Tptp.Node>()

    var symbol: String = ""
    var nodes : [Tptp.Node]? = nil

    lazy var hashValue : Int = self.calcHashValue()
    lazy var description : String = self.tptpDescription()
  }
}

extension Node where Symbol == String {
  init(tree:TreeNodeRef) {

    let name = tree.symbol ?? "n/a"
    let nodes : [Self]? =
      tree.type == PRLC_VARIABLE ?
      nil : tree.children.map { Self(tree:$0) }

    self.init(symbol:name, nodes:nodes)
  }
}
