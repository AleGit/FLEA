

struct Tptp {

  typealias S = Tptp.Symbol   // choose a symbol type
  typealias Node = KinNode  // choose an implementation

  /// equal nodes are not always the same object
  /// depending on the method to build composite nodes
  final class SimpleNode : FLEA.Node {
    var symbol = S.empty
    var nodes : [Tptp.SimpleNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// allNodes holds string references to all created nodes,
  /// i.e. all nodes are permanent
  final class SharingNode : FLEA.SharingNode {
    static var allNodes = Set<Tptp.SharingNode>()

    var symbol = S.empty
    var nodes : [Tptp.SharingNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// allNodes holds weak references to all created nodes,
  /// i.e. temporary nodes are possible
  final class SmartNode : FLEA.SharingNode {
    static var allNodes = WeakSet<Tptp.SmartNode>()

    var symbol = S.empty
    var nodes : [Tptp.SmartNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// allNodes holds weak references to all created nodes,
  /// parents are a weak collection of a node's predecessors
  final class KinNode : FLEA.KinNode {
    static var allNodes = WeakSet<Tptp.KinNode>()
    var symbol = S.empty
    var nodes : [Tptp.KinNode]? = nil
    var parents =  WeakSet<Tptp.KinNode>()

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription

  }
}
