//  Copyright © 2016 Alexander Maringele. All rights reserved.

struct Tptp {
  static let wildcard = "*"

  typealias S = Tptp.Symbol   // choose a symbol type
  typealias I = Int
  typealias DefaultNode = KinNode    // choose an implementation

  /// equal nodes are not always the same object
  /// depending on the method to build composite nodes
  final class SimpleNode: SymbolStringTyped, Node,
  ExpressibleByStringLiteral {
    var symbol = S(wildcard, .variable)
    var nodes: [Tptp.SimpleNode]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// pool holds string references to all created nodes,
  /// i.e. all nodes are permanent
  final class SharingNode: SymbolStringTyped, Sharing, Node,
  ExpressibleByStringLiteral {
    static var pool = Set<Tptp.SharingNode>()

    var symbol = S(wildcard, .variable)
    var nodes: [Tptp.SharingNode]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes.
  final class SmartNode: SymbolStringTyped, Sharing, Node,
  ExpressibleByStringLiteral {
    static var pool = WeakSet<Tptp.SmartNode>()

    var symbol = S(wildcard, .variable)
    var nodes: [Tptp.SmartNode]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
  }

  final class SmartIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<KinIntNode>()

    var symbol: Int = SmartIntNode.symbolize(string:wildcard, type:.variable)
    var nodes: [SmartIntNode]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
  }

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes,
  /// `folks` holds weak references to node's predecessors
  final class KinNode: SymbolStringTyped, Sharing, Kin, Node, ExpressibleByStringLiteral {
    static var pool = WeakSet<Tptp.KinNode>()
    var folks =  WeakSet<Tptp.KinNode>()

    var symbol = S(wildcard, .variable)
    var nodes: [Tptp.KinNode]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
  }

  final class KinIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node,
  ExpressibleByStringLiteral {
    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<KinIntNode>()
    var folks = WeakSet<KinIntNode>()

    var symbol: Int = KinIntNode.symbolize(string:wildcard, type:.variable)
    var nodes: [KinIntNode]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    lazy var description: String = self.defaultDescription
  }
}
