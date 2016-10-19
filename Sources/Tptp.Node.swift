//  Copyright © 2016 Alexander Maringele. All rights reserved.

struct Tptp {
  static let wildcard = "*"

  typealias S = Tptp.Symbol   // choose a symbol type
  typealias I = Int
  typealias DefaultNode = KinNode    // choose an implementation

  /* simple *************************************************************************/

  /// equal nodes are not always the same object
  /// depending on the method to build composite nodes
  final class SimpleNode: SymbolStringTyped, Node,
  ExpressibleByStringLiteral {
    typealias N = SimpleNode

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil
  }

  final class SimpleIntNode: SymbolStringTyped, SymbolTabulating, Node,
  ExpressibleByStringLiteral {
    typealias N = SimpleIntNode

    static var symbols = StringIntegerTable<I>()

    var symbol: Int = N.symbolize(string:wildcard, type:.variable)
    var nodes: [N]? = nil
  }

  /* sharing (strong) *************************************************************************/

  /// equal nodes are the same objects
  /// pool holds string references to all created nodes,
  /// i.e. all nodes are permanent
  final class SharingNode: SymbolStringTyped, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SharingNode

    static var pool = Set<N>()

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  final class SharingIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SharingIntNode

    static var symbols = StringIntegerTable<I>()
    static var pool = Set<N>()

    var symbol: Int = N.symbolize(string:wildcard, type:.variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  /* sharing (weak) *************************************************************************/

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes.
  final class SmartNode: SymbolStringTyped, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SmartNode

    static var pool = WeakSet<N>()

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    var description: String { return self.defaultDescription }
  }

  final class SmartIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SmartIntNode

    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<N>()

    var symbol: Int = SmartIntNode.symbolize(string:wildcard, type:.variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  /* sharing and kin s(weak) *************************************************************************/

  /// equal nodes are the same objects
  /// `pool` holds weak references to all created nodes,
  /// `folks` holds weak references to node's predecessors
  final class KinNode: SymbolStringTyped, Sharing, Kin, Node, ExpressibleByStringLiteral {
    typealias N = Tptp.KinNode

    static var pool = WeakSet<N>()
    var folks =  WeakSet<N>()

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  final class KinIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.KinIntNode

    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()

    var symbol: Int = N.symbolize(string:wildcard, type:.variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }
}
