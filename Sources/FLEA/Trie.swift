import Foundation

// MARK: - a generic trie protocol

protocol Trie {
    associatedtype Leap
    associatedtype Value
    associatedtype LeapS: Sequence // a sequence of leaps is a path, i.e. key
    associatedtype ValueS: Sequence // a sequence of stored values
    associatedtype TrieS: Sequence // a sequence of (sub)tries

    /// creates empty trie type
    init()

    /// creates a trie with one value at path.
    init<C: Collection>(with: Value, at path: C)
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */

    /// inserts one value at Leap path
    mutating func insert<C: Collection>(_ newMember: Value, at path: C)
        -> (inserted: Bool, memberAfterInsert: Value)
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */

    /// removes and returns one value at Leap path,
    /// if path or value do not exist trie stays unchanged and nil is returned
    mutating func remove<C: Collection>(_ value: Value, at path: C) -> Value?
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */

    /// returns all values at path
    func retrieve<C: Collection>(from path: C) -> ValueS?
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */

    /// stores one value at trie node
    mutating func insert(_ newMember: Value) -> (inserted: Bool, memberAfterInsert: Value)

    /// removes and returns one value from trie node
    mutating func remove(_ member: Value) -> Value?

    /// Get (or set) subnode with step.
    /// For efficiency the Setter MUST NOT store an empty trie,
    /// i.e. trie where no value is stored at any node.
    subscript(_: Leap) -> Self? { get set }

    /// get values at one trie node
    var values: ValueS { get }

    /// collect values at all immediate subtries
    // var subvalues : ValueS { get }

    var leaps: LeapS { get }

    /// get all immediate subtries
    var tries: TrieS { get }

    /// A trie is empty iff no value is stored at any node.
    /// _complexity_: O(1) when no empty subtries are kept.
    var isEmpty: Bool { get }
}

// MARK: default implementations for init, insert, remove, retrieve

extension Trie {

    /// Create a new trie with one value at path.
    init<C: Collection>(with value: Value, at path: C)
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */ {
        self.init() // initialize trie
        _ = insert(value, at: path)
    }

    /// Inserts value at path. Possibly missing subtrie is created.
    @discardableResult
    mutating func insert<C: Collection>(_ newMember: Value, at path: C)
        -> (inserted: Bool, memberAfterInsert: Value)
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */ {
        guard let (head, tail) = path.decomposing else {
            return insert(newMember)
        }

        if self[head] == nil {
            self[head] = Self(with: newMember, at: tail)
            return (true, newMember)
        } else {
            return self[head]!.insert(newMember, at: tail)
        }
    }

    /// remove value at path. Returns removed value or nil
    /// if path does not exist or value was not stored at path.
    /// Empty subtries are removed.
    mutating func remove<C: Collection>(_ member: Value, at path: C) -> Value?
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */ {
        guard let (head, tail) = path.decomposing else {
            return remove(member)
        }
        guard var trie = self[head] else { return nil }
        let removedMember = trie.remove(member, at: tail)
        self[head] = trie // setter MUST NOT store an empty trie!
        return removedMember // could be different from member
    }

    /// Returns values at path or nil if path does not exist.
    func retrieve<C: Collection>(from path: C) -> ValueS?
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */ {
        guard let (head, tail) = path.decomposing else {
            return values
        }
        guard let trie = self[head] else { return nil }
        return trie.retrieve(from: tail)
    }
}

func ==<T: Trie>(lhs: T, rhs: T) -> Bool
    where T.ValueS == Set<T.Value>, T.LeapS == Set<T.Leap> {
    guard lhs.values == rhs.values else { return false }
    guard lhs.leaps == rhs.leaps else { return false }

    return true
}

// MARK: - trie with hashable leaps and values

protocol TrieStore: Trie, Equatable where Self.Leap: Hashable, Self.Value: Hashable {
    var trieStore: [Leap: Self] { set get }
    var valueStore: Set<Value> { set get }
}

extension TrieStore {
    /// It is assumed that no empty subtries are stored, i.e.
    /// the trie has to be carefully maintained when values are removed.
    /// _Complexity_: O(1)
    var isEmpty: Bool {
        return valueStore.isEmpty && trieStore.isEmpty
        // valueStore.isEmtpy is obviously necessary
        // then valueStore.isEmtpy is obviously sufficiant,
        // but not necessary when empty subtries are possible.
    }
}

extension TrieStore {

    mutating func insert(_ newMember: Value) -> (inserted: Bool, memberAfterInsert: Value) {
        return valueStore.insert(newMember)
    }

    mutating func remove(_ member: Value) -> Value? {
        return valueStore.remove(member)
    }

    subscript(key: Leap) -> Self? {
        get { return trieStore[key] }

        /// setter MUST NOT store an empty trie
        set {
            trieStore[key] = (newValue?.isEmpty ?? true) ? nil : newValue
        }
    }

    var values: Set<Value> {
        return valueStore
    }

    /// Complexity : O(n)
    var allValues: Set<Value> {
        return valueStore.union(
            trieStore.values.flatMap { $0.allValues }
        )
    }

    var leaps: Set<Leap> {
        return Set(trieStore.keys)
    }

    var tries: [Self] {
        let ts = trieStore.values
        return Array(ts)
    }
}

extension TrieStore {
    /// `wildcard` must be distinct from all other leap values, e.g.
    /// Leap == Int => wildcard must not conflict with positions, i.e. wildcard < 0
    /// Leap == SymHop<String> => wildcard = SymHop.symbol("*")
    private func values<C: Collection>(prefix path: C, wildcard: Leap) -> Set<Value>?
        where C.Iterator.Element == Leap /* , C.SubSequence: Collection */ {
        guard let (head, tail) = path.decomposing, head != wildcard else {
            // empty path, i.e. a) leave node or b) wildcard
            assert(
                allValues.count > 0,
                "All values MUST NOT be empty, because empty branches MUST have been removed."
            )
            // a) all values of the actual node                                should be returned
            // b) all values of the actual node and the values of all subnodes should be returned

            // since a leave node has no sub nodes a) and b) matches

            return allValues
        }

        // ensured: head != nil && head != wildcard
        // subtrie for head MAY NOT exist

        guard let subtrie = self[head] else {
            // ensured: subtrie for head does not exist
            // subtrie for wildcard MAY NOT exist
            return self[wildcard]?.allValues
        }

        // ensured: subtrie for head exists

        guard let values = self[wildcard]?.allValues else {
            // ensured: subtrie for wildcard does not exist
            // unifiables for tail MAY not exist
            return subtrie.values(prefix: tail, wildcard: wildcard)
        }

        assert(
            values.count > 0,
            "All values MUST NOT be empty, because empty branches MUST have been removed."
        )
        // ensured: values for wildcard exist
        // unifiables for tail MAY not exist

        guard let subvalues = subtrie.values(prefix: tail, wildcard: wildcard) else {
            // ensured: unifiables for tail do not exist
            return values
        }
        assert(
            subvalues.count > 0,
            "Valuse MUST not be empty, because empty nodes MUST have been removed."
        )
        // ensured: unifiables for tail exist

        return values.union(subvalues)
    }

    /// find candidates for unification by term paths
    /// 1 f(c,Y) =>      f.1.c:1, f.2.*:1
    /// 2 f(X,f(Y,Z)) => f.1.*:2, f.2.f.1.*:2, f.2.f.2.*:2
    /// 3 f(c,d) =>      f.1.c:3, f.2.d:3
    /// 1 and 2 match, 1 and 3 match, 2 and 3 do not match
    func unifiables(paths: [[Leap]], wildcard: Leap) -> Set<Value>? {

        guard let (first, reminder) = paths.decomposing else {
            Syslog.error { "SHOULD not call \(#function) with empty list of paths" }
            return allValues // correct, but useless
        }

        guard var result = values(prefix: first, wildcard: wildcard), result.count > 0 else {
            // ensured: nothing matches the first path
            return nil
        }

        for path in reminder {
            guard let unifiables = values(prefix: path, wildcard: wildcard), unifiables.count > 0 else {
                // ensured: nothing matches the actual path
                return nil
            }
            // ensured: all paths had matches so far

            result.formIntersection(unifiables)
            guard result.count > 0 else {
                // ensured: intersection of matches is already empty
                return nil
            }

            // ensured: intersection of matches so far is still not empty
        }

        // ensured: all paths had matches
        // ensured: intersection of matches is not empty

        return result
    }
}

// MARK: - concrete trie implementations

// MARK: concrete value trie type

struct TrieStruct<K: Hashable, V: Hashable>: TrieStore {
    typealias Leap = K
    typealias Value = V
    var trieStore = [Leap: TrieStruct<K, V>]()
    var valueStore = Set<V>()
}

// MARK: concrete reference trie type

final class TrieClass<K: Hashable, V: Hashable>: TrieStore {
    typealias Leap = K
    typealias Value = V
    var trieStore = [Leap: TrieClass<Leap, Value>]()
    var valueStore = Set<Value>()
}
