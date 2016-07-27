
/// Collections suitable for sharing nodes just implement SetAlgebra.insert(:)
protocol PartialSetAlgebra {
  associatedtype Element
  mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
  func contains(_ member: Element) -> Bool
}

protocol Sharing : class {
  associatedtype M : PartialSetAlgebra
  static var pool : M { get set }
}

protocol Kin : class {
    associatedtype P : WeakPartialSetAlgebra
    var folks : P { get set }
}

protocol WeakPartialSetAlgebra : PartialSetAlgebra {}


extension Set : PartialSetAlgebra {}       // Set : SetAlgebra
extension WeakSet : PartialSetAlgebra {}
extension WeakSet : WeakPartialSetAlgebra {}

/// A sharing node is a specialized node where
/// a collection of all created nodes is held.
/// Unique instances of nodes are shared between (sub)trees.
/// Sharing is suitable for immutable reference types.
protocol SharingNode : Sharing, Node { }

extension Node where Self:Sharing, Self.M.Element == Self {
  /// By default smart nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    return pool.insert(node).memberAfterInsert
  }
}

/// If the collection is of the right type, perfect sharing will work automatically.
extension SharingNode where M.Element == Self {
  /// By default smart nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    return pool.insert(node).memberAfterInsert
  }
}

/// kin nodes are sharing, additionally
/// they hold weak references to all their folks
protocol KinNode : Kin, Sharing, Node { }

extension Node where Self:Kin, Self:Sharing, Self.M.Element==Self, Self.P.Element==Self {
  static func share(node:Self) -> Self {
    let member = pool.insert(node).memberAfterInsert

    if let nodes = member.nodes {
      for n in nodes {
        let _ = n.folks.insert(member)
      }
    }
    return member
  }
}
