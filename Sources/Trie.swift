import Foundation

// MARK: - a generic trie protocol

protocol Trie {
    associatedtype Leap
    associatedtype Value
    associatedtype LeapS : Sequence// a sequence of leaps is a path, i.e. key
    associatedtype ValueS : Sequence // a sequence of stored values
    associatedtype TrieS : Sequence // a sequence of (sub)tries

    /// creates empty trie type
    init()

    /// creates a trie with one value at path.
    init<C: Collection>(with: Value, at path: C)
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// inserts one value at Leap path
    mutating func insert<C: Collection>(_ newMember:Value, at path: C)
    -> (inserted: Bool, memberAfterInsert: Value)
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// removes and returns one value at Leap path,
    /// if path or value do not exist trie stays unchanged and nil is returned
    mutating func remove<C: Collection>(_ value:Value, at path: C) -> Value?
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// returns all values at path
    func retrieve<C: Collection>(from path: C) -> ValueS?
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// stores one value at trie node
    mutating func insert(_ newMember: Value) -> (inserted: Bool, memberAfterInsert: Value)

    /// removes and returns one value from trie node
    mutating func remove(_ member: Value) -> Value?

    /// Get (or set) subnode with step.
    /// For efficiency the Setter MUST NOT store an empty trie,
    /// i.e. trie where no value is stored at any node.
    subscript(step: Leap) -> Self? { get set }

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
  where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
  C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence {
    self.init() // initialize trie
    let _ = self.insert(value, at: path)
  }

  /// Inserts value at path. Possibly missing subtrie is created.
  @discardableResult
  mutating func insert<C: Collection>(_ newMember: Value, at path: C)
  -> (inserted:Bool, memberAfterInsert:Value)
  where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
  C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence {
    guard let (head, tail) = path.decomposing else {
      return self.insert(newMember)
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
  where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
  C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence {
    guard let (head, tail) = path.decomposing else {
      return self.remove(member)
    }
    guard var trie = self[head] else { return nil }
    let removedMember = trie.remove(member, at:tail)
    self[head] = trie // setter MUST NOT store an empty trie!
    return removedMember // could be different from member
  }

  /// Returns values at path or nil if path does not exist.
  func retrieve<C: Collection>(from path: C) -> ValueS?
  where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
  C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence {
    guard let (head, tail) = path.decomposing else {
      return values
    }
    guard let trie = self[head] else { return nil }
    return trie.retrieve(from:tail)
  }
}

func ==<T: Trie>(lhs: T, rhs: T) -> Bool
where T.Value:Hashable, T.Leap:Hashable, T.ValueS == Set<T.Value>, T.LeapS == Set<T.Leap> {
  guard lhs.values == rhs.values else { return false }
  guard lhs.leaps == rhs.leaps else { return false }

  return true
}

// MARK: - trie with hashable leaps and values

protocol TrieStore: Trie, Equatable {
  associatedtype Leap : Hashable
  associatedtype Value : Hashable

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

extension TrieStore where Leap == Int, Value == Int {
  @available(*, deprecated, message: "Use `unifiables` instead!")

  func candidates(from path: [Int], x: Int = -1) -> Set<Int>? {
    guard let (head, tail) = path.decomposing else {
      assert(false)
      return values
    }

    switch (head, tail.count) {
      case (x, 0):
      // variable at end of path end of path
      // (*,[])
      return self.allValues

      case (_, 0):
      // constant at end of path end of path
      // (a,[])
      return self[head]?.valueStore

      case (_, _) where tail.count % 2 == 1:
      // (n,[X]) of (n,[f,0,X]) etc.
      guard let trie = self[head] else { return nil }
      return trie.candidates(from:Array(tail))

      case (_, _) where tail.count % 2 == 0:
      guard var vs = self[x]?.allValues else {
        return self[head]?.candidates(from:Array(tail))
      }
      guard let cs = self[head]?.candidates(from:Array(tail)) else {
        return vs
      }
      vs.formUnion(cs)
      return vs

      default:
      assert(false)
      return nil
    }

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
      return self.valueStore
  }


  /// Complexity : O(n)
  var allValues: Set<Value> {
    return self.valueStore.union (
      trieStore.values.flatMap { $0.allValues }
    )
  }


  var leaps: Set<Leap> {
    return Set(self.trieStore.keys)
  }

  var tries: [Self] {
      let ts = trieStore.values
      return Array(ts)
  }
}

extension TrieStore {
  /// `wildcard` must be distinct from all other leap values,
  /// e.g. Int == Leap => asterisk must not conflict with positions, i.e. asterisk < 0
  private func unifiables<C: Collection>(path: C, wildcard: Leap) -> Set<Value>?
  where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
  C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence {
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
      return subtrie.unifiables(path: tail, wildcard: wildcard)
    }

    assert(
      values.count > 0,
      "All values MUST NOT be empty, because empty branches MUST have been removed."
    )
    // ensured: values for wildcard exist
    // unifiables for tail MAY not exist

    guard let subvalues = subtrie.unifiables(path: tail, wildcard: wildcard) else {
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
      assert(false, "SHOULD not call \(#function) with empty list of paths")
      return allValues // correct, but useless
    }

    guard var result = unifiables(path: first, wildcard:wildcard), result.count > 0 else {
      // ensured: nothing matches the first path
      return nil
    }

    for path in reminder {
      guard let unifiables = unifiables(path: path, wildcard: wildcard), unifiables.count > 0 else {
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

struct TrieStruct<K: Hashable, V: Hashable> : TrieStore {
  typealias Key = K
  typealias Value = V
  var trieStore = [Key: TrieStruct<Key, Value>]()
  var valueStore = Set<Value>()
}

// MARK: concrete reference trie type

final class TrieClass<K: Hashable, V: Hashable> : TrieStore {
  typealias Key = K
  typealias Value = V
  var trieStore = [Key: TrieClass<Key, Value>]()
  var valueStore = Set<Value>()
}
