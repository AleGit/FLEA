

struct Tptp {

  typealias S = Tptp.Symbol   // choose a symbol type
  typealias Node = KinNode    // choose an implementation

  /// equal nodes are not always the same object
  /// depending on the method to build composite nodes
  final class SimpleNode : FLEA.Node, StringLiteralConvertible {
    var symbol = S.empty
    var nodes : [Tptp.SimpleNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// pool holds string references to all created nodes,
  /// i.e. all nodes are permanent
  final class SharingNode : FLEA.SharingNode {
    static var pool = Set<Tptp.SharingNode>()

    var symbol = S.empty
    var nodes : [Tptp.SharingNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes.
  final class SmartNode : FLEA.SharingNode {
    static var pool = WeakSet<Tptp.SmartNode>()

    var symbol = S.empty
    var nodes : [Tptp.SmartNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes,
  /// `folks` holds weak references to node's predecessors
  final class KinNode : FLEA.KinNode {
    static var pool = WeakSet<Tptp.KinNode>()
    var symbol = S.empty
    var nodes : [Tptp.KinNode]? = nil
    var folks =  WeakSet<Tptp.KinNode>()

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  final class KinIntNode : FLEA.KinNode, FLEA.SymbolTableUser {
    static var pool = WeakSet<KinIntNode>()
    static var symbols = IntegerSymbolTable<Int>()

    var symbol = Int.max
    var nodes : [KinIntNode]? = nil
    var folks = WeakSet<KinIntNode>()



    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription



  }
}
