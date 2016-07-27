

struct Tptp {

  typealias S = Tptp.Symbol   // reliable type information
  typealias Node = SmartNode  // choose an implementation

  final class SimpleNode : FLEA.Node {
    var symbol = S.empty
    var nodes : [Tptp.SimpleNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  // equal nodes are the same objects
  // allNodes holds string references to all created nodes
  final class SharingNode : FLEA.SmartNode {
    static var allNodes = Set<Tptp.SharingNode>()

    var symbol = S.empty
    var nodes : [Tptp.SharingNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription

  }

  // equal nodes are the same objects
  // allNodes holds weak references to all created nodes
  final class SmartNode : FLEA.SmartNode {
    static var allNodes = WeakSet<Tptp.SmartNode>()

    var symbol = S.empty
    var nodes : [Tptp.SmartNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }
}
