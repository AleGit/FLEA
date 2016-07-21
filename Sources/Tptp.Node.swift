

struct Tptp {

  typealias Node = SmartNode  // choose an implementation

  final class SimpleNode : FLEA.Node {
    var symbol = Tptp.Symbol("n/a",.Undefined)
    var nodes : [Tptp.SimpleNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  // equal nodes are the same objects
  // allNodes holds string references to all created nodes
  final class SharingNode : FLEA.SharingNode {
    static var allNodes = Set<Tptp.SharingNode>()

    var symbol = Tptp.Symbol("",.Undefined)
    var nodes : [Tptp.SharingNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription

  }

  // equal nodes are the same objects
  // allNodes holds weak references to all created nodes
  final class SmartNode : FLEA.SmartNode {
    static var allNodes = WeakSet<Tptp.SmartNode>()

    var symbol = Tptp.Symbol("",.Undefined)
    var nodes : [Tptp.SmartNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }
}
