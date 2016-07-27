/// A sharing node is a specialized node where
/// a collection of all created nodes is held.
/// Unique instances of nodes are shared between (sub)trees.
/// Sharing is suitable for immutable reference types.

protocol MemberAfterInsert {
  associatedtype Element
  mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
}

extension Set : MemberAfterInsert {}
extension WeakSet : MemberAfterInsert {}

protocol SmartNode : class, Node {
  associatedtype M : MemberAfterInsert
  static var allNodes : M { get set }
}

extension SmartNode where M.Element == Self {
  /// By default smart nodes are shared between trees,
  /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
  static func share(node:Self) -> Self {
    return allNodes.insert(node).memberAfterInsert
  }
}
