
/// Collections suitable for sharing nodes just implement SetAlgebra.insert(:)
protocol PartialSetAlgebra {
  associatedtype Element
  mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
  func contains(_ member: Element) -> Bool
}

protocol WeakPartialSetAlgebra : PartialSetAlgebra {}


extension Set : PartialSetAlgebra {}       // Set : SetAlgebra
extension WeakSet : PartialSetAlgebra {}
extension WeakSet : WeakPartialSetAlgebra {}

/// A sharing node is a specialized node where
/// a collection of all created nodes is held.
/// Unique instances of nodes are shared between (sub)trees.
/// Sharing is suitable for immutable reference types.
protocol SharingNode : class, Node {
  associatedtype M : PartialSetAlgebra
  static var allNodes : M { get set }
}

/// If the collection is of the right type, perfect sharing will work automatically.
extension SharingNode where M.Element == Self {
  /// By default smart nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    return allNodes.insert(node).memberAfterInsert
  }
}

/// kin nodes hold references are sharing and hold references to all their parents
protocol KinNode : class, Node {
  associatedtype M : PartialSetAlgebra
  associatedtype P : WeakPartialSetAlgebra
  static var allNodes : M { get set }
  var parents : P { get set}
}


extension KinNode where M.Element == Self, P.Element == Self {
  static func share(node:Self) -> Self {
    let member = allNodes.insert(node).memberAfterInsert

    if let nodes = member.nodes {
      for n in nodes {
        let _ = n.parents.insert(member)
      }
    }
    return member
  }
}
