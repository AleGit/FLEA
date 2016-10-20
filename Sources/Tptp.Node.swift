//  Copyright © 2016 Alexander Maringele. All rights reserved.

struct Tptp {
  static let wildcard = "*"

  typealias S = Tptp.Symbol   // choose a symbol type
  typealias I = Int
  typealias DefaultNode = SmartIntNode    // choose an implementation

  /* sample implementations of protocol `Node` and related protocols
    - SymbolStringTyped
    - SymbolTabulating
    - Sharing
    - Kin
    */

  /* simple *************************************************************************/

  @available(*, deprecated, message: "- Tptp.SimpleNode is for demo purposes only -")
  final class SimpleNode: SymbolStringTyped, Node,
  ExpressibleByStringLiteral {
    typealias N = SimpleNode

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil
  }

  /// The simplest node implementation with an integer symbol and a symbol table.
  /// sharing is possible but happens by accident,
  /// i.e. equal nodes may or may not reference the same object
  final class SimpleIntNode: SymbolStringTyped, SymbolTabulating, Node,
  ExpressibleByStringLiteral {
    typealias N = SimpleIntNode

    static var symbols = StringIntegerTable<I>()

    var symbol: Int = N.symbolize(string:wildcard, type:.variable)
    var nodes: [N]? = nil
  }

  /* sharing (strong) *************************************************************************/

  @available(*, deprecated, message: "- Tptp.SharingNode suffers from node accumulation and is for demo purposes only -")
  final class SharingNode: SymbolStringTyped, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SharingNode

    static var pool = Set<N>()

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  /// A simple sharing node implementation with an integer symbol and a symbol table.
  /// - the sharing is automatic and perfect for ground terms
  /// - all (sub)nodes are strongly referenced by a `pool` (a set),
  ///   i.e. all nodes stay in memory (node accumulation)
  @available(*, deprecated, message: "- Tptp.SharingIntNode suffers from node accumulation and is for demo purposes only -")
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

  @available(*, deprecated, message: "- Tptp.SmartNode is for demo purposes only -")
  final class SmartNode: SymbolStringTyped, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SmartNode

    static var pool = WeakSet<N>()

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
    var description: String { return self.defaultDescription }
  }

  /// A smarter sharing node implementation with an integer symbol and a symbol table.
  /// - the sharing is automatic and perfect for ground terms
  /// - all (sub)nodes are weakly referenced by a `pool` (a setlike collection),
  ///   i.e. nodes only stay in memory when they are referenced outside the pool too.
  final class SmartIntNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias N = Tptp.SmartIntNode

    static var symbols = StringIntegerTable<Int>()
    static var pool = WeakSet<N>()

    var symbol: Int = SmartIntNode.symbolize(string:wildcard, type:.variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  /* sharing and kin (weak) *************************************************************************/

  @available(*, deprecated, message: "- Tptp.KinNode is for demo purposes only -")
  final class KinNode: SymbolStringTyped, Sharing, Kin, Node, ExpressibleByStringLiteral {
    typealias N = Tptp.KinNode

    static var pool = WeakSet<N>()
    var folks =  WeakSet<N>()

    var symbol = S(wildcard, .variable)
    var nodes: [N]? = nil

    lazy var hashValue: Int = self.defaultHashValue
  }

  /// A sharing node implementation with an integer symbol, a symbol table, and
  /// back references from nodes to all its predecessors.
  /// - the sharing is automatic and perfect for ground terms
  /// - the back references are automatic
  /// - all (sub)nodes are weakly referenced by a `pool` (a setlike collection),
  ///   i.e. nodes only stay in memory when they are referenced outside the pool too.
  /// - all predecessors are weakly referenced, i.e. no retain cycles occur.
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
