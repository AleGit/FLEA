

struct Tptp {

  final class Node : FLEA.SharingNode {
    static var allNodes = Set<Tptp.Node>()

    var symbol = Tptp.Symbol("n/a",.Undefined)
    var nodes : [Tptp.Node]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }
}
