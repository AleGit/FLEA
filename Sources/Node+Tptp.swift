import CTptpParsing

struct TPTP {
  static var inits = 0
  static var deinits = 0

  final class Node : FLEA.SharingNode {
    init() {
      TPTP.inits += 1
    }
    deinit {
      TPTP.deinits += 1
    }

    static var sharedNodes = Set<TPTP.Node>()

    var symbol: String = ""
    var nodes : [TPTP.Node]? = nil

    lazy var hashValue : Int = self.calcHashValue()
    lazy var description : String = self.tptpDescription()
  }
}

extension Node where Symbol == String {
  init(tree:TreeNodeRef) {

    let name = tree.symbol ?? "n/a"
    let nodes : [Self]? = tree.type == PRLC_VARIABLE ? nil :
    tree.children.map { Self(tree:$0) }

    self.init(symbol:name, nodes:nodes)
  }

}
