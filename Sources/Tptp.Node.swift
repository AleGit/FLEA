

struct Tptp {

  typealias S = Tptp.Symbol   // choose a symbol type
  typealias DefaultNode = KinNode    // choose an implementation

  /// equal nodes are not always the same object
  /// depending on the method to build composite nodes
  final class SimpleNode : SymbolStringTyped, Node, ExpressibleByStringLiteral {
    var symbol = S("",.undefined)
    var nodes : [Tptp.SimpleNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// pool holds string references to all created nodes,
  /// i.e. all nodes are permanent
  final class SharingNode : SymbolStringTyped, Sharing, Node, ExpressibleByStringLiteral {
    static var pool = Set<Tptp.SharingNode>()

    var symbol = S("",.undefined)
    var nodes : [Tptp.SharingNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes.
  final class SmartNode : SymbolStringTyped, Sharing, Node, ExpressibleByStringLiteral {
    static var pool = WeakSet<Tptp.SmartNode>()

    var symbol = S("",.undefined)
    var nodes : [Tptp.SmartNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes,
  /// `folks` holds weak references to node's predecessors
  final class KinNode : SymbolStringTyped, Sharing, Kin, Node, ExpressibleByStringLiteral {
    static var pool = WeakSet<Tptp.KinNode>()
    var symbol = S("",.undefined)
    var nodes : [Tptp.KinNode]? = nil
    var folks =  WeakSet<Tptp.KinNode>()

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  final class KinIntNode : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node, ExpressibleByStringLiteral {
    static var pool = WeakSet<KinIntNode>()
    static var symbols = StringIntegerTable<Int>()

    var symbol = symbols.insert("",.undefined)
    var nodes : [KinIntNode]? = nil
    var folks = WeakSet<KinIntNode>()

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }
}
