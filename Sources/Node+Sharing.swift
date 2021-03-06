/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// mark a type as sharing and enforce a global storage pool of unique instances
/// in most a cases a weak references are sufficient and preferable
protocol Sharing: class {
    associatedtype M: PartialSetAlgebra // WeakPartialSetAlgebra : PartialSetAlgebra
    static var pool: M { get set }
}

/// mark a type as holding weak references to immediate ancestors, i.e. folks
protocol Kin: class {
    associatedtype P: WeakPartialSetAlgebra
    var folks: P { get set }
}

/// A sharing node is a specialized node where
/// a collection of all created nodes is held.
/// Unique instances of nodes are shared within and between trees.
/// Sharing is suitable for immutable reference types.
// protocol SharingNode : Sharing, Node { }

extension Node where Self: Sharing, Self.M.Element == Self {
    /// By default smart nodes are shared between trees,
    /// e.g. one unique instance of variable `X` in `p(X,f(X,X))`.
    static func share(node: Self) -> Self {
        return pool.insert(node).memberAfterInsert
    }
}

/// A sharing kin node is a sharing node, additionally
/// it holds weak references to all its folks.

extension Node where Self: Kin, Self: Sharing, Self.M.Element == Self, Self.P.Element == Self {
    static func share(node: Self) -> Self {
        let member = pool.insert(node).memberAfterInsert

        if let nodes = member.nodes {
            for n in nodes {
                _ = n.folks.insert(member)
            }
        }
        return member
    }
}
