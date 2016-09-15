import Foundation


protocol Trie {
    associatedtype Leap
    associatedtype Value
    associatedtype LeapS : Sequence// a sequence of leaps is a path, i.e. key
    associatedtype ValueS : Sequence // a sequence of stored values
    associatedtype TrieS : Sequence // a sequence of (sub)tries

    /// creates empty trie type
    init()

    /// creates a trie with one value at path.
    init<C: Collection>(with: Value, at: C)
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// inserts one value at Leap path
    mutating func insert<C: Collection>(_ newMember:Value, at: C)
    -> (inserted: Bool, memberAfterInsert: Value)
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// removes and returns one value at Leap path,
    /// if path or value do not exist trie stays unchanged and nil is returned
    mutating func remove<C: Collection>(_ value:Value, at: C) -> Value?
    where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
    C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence

    /// returns all values at path
    func retrieve<C: Collection>(from: C) -> ValueS?
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
    }
    else {
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

func ==<T:Trie>(lhs: T, rhs: T) -> Bool
where T.Value:Hashable, T.Leap:Hashable, T.ValueS == Set<T.Value>, T.LeapS == Set<T.Leap> {
  guard lhs.values == rhs.values else { return false }
  guard lhs.leaps == rhs.leaps else { return false }

  return true
}

// MARK: a trie with hashable leaps and values



protocol TrieStore: Trie, Equatable {
  associatedtype Leap : Hashable
  associatedtype Value : Hashable

  var trieStore: [Leap: Self]  { set get }
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
  func candidates(from path: [Int], x: Int = -1) -> Set<Int>? {


    /*
    guard let (head,tail) = path.decomposing else {
      return values
    }
    guard let trie = self[head] else { return nil }
    return trie.retrieve(from:tail)
    */
    guard let (head, tail) = path.decomposing else {
      assert(false)
      return values
    }

    switch (head, tail.count) {
      case (x,0):
      // variable at end of path end of path
      // (*,[])
      return self.allValues

      case (_, 0):
      // constant at end of path end of path
      // (a,[])
      return self[head]?.valueStore

      case (_,_) where tail.count % 2 == 1:
      // (n,[X]) of (n,[f,0,X]) etc.
      guard let trie = self[head] else { return nil }
      return trie.candidates(from:Array(tail))

      case (_,_) where tail.count % 2 == 0:
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

// extension Trie where Value==Int {
//     typealias LeapPath = [Leap]
//
//     mutating func fill<N:Node, R:Sequence, S:Sequence where
//         R.Iterator.Element == N,
//         S.Iterator.Element == LeapPath>(_ nodes:R, paths:(N) -> S ) {
//             for (index,node) in nodes.enumerated() {
//                 for path in paths(node) {
//                     self.insert(path, value:index)
//                 }
//             }
//     }
//
//     mutating func fill<N:Node, R:Sequence where
//         R.Iterator.Element == N>(_ nodes:R, path:(N) -> LeapPath) {
//             for (index,node) in nodes.enumerated() {
//                 self.insert(path(node), value:index)
//             }
//     }
// }

extension TrieStore {
  /// values asterisk must be different from all other leap values,
  /// e.g. Int == Leap => asterisk must not conflict with positions, i.e. asterisk < 0
  func unifiables<C: Collection>(path: C, wildcard: Leap) -> Set<Value>?
  where C.Iterator.Element == Leap, C.SubSequence.Iterator.Element == Leap,
  C.SubSequence:Collection, C.SubSequence.SubSequence == C.SubSequence {
    guard let (head, tail) = path.decomposing, head != wildcard else {
      // leaf or *
      assert(allValues.count > 0)
      return allValues // MUST NOT be empty, because empty leaves have to be removed
    }

    guard let subtrie = self[head] else {
      return self[wildcard]?.allValues // MAY be nil
    }

    guard let values = self[wildcard]?.allValues else {
      return subtrie.unifiables(path: tail, wildcard: wildcard) // MAY be nil
    }

    assert(values.count > 0)

    guard let subvalues = subtrie.unifiables(path: tail, wildcard: wildcard) else {
      return values
    }

    assert(subvalues.count > 0)

    return values.union(subvalues)
  }

  func unifiables(paths: [[Leap]], wildcard: Leap) -> Set<Value>? {

    guard let (head, tail) = paths.decomposing else {
      assert(false, "SHOULD not call \(#function) with empty list of paths")
      return allValues // correct, but useless
    }

    guard var result = unifiables(path: head, wildcard:wildcard), result.count > 0 else {
      return nil
    }

    for path in tail {
      guard let unifiables = unifiables(path: path, wildcard: wildcard), unifiables.count > 0 else {
        return nil
      }
      result.formIntersection(unifiables)
      guard result.count > 0 else {
        return nil
      }
    }

    return result

  }
}

// func extractUnifiables<T:TrieType where T.Leap==SymHop<String>, T.Value:Hashable>(_ trie:T, path:[T.Leap]) -> Set<T.Value>? {
//     guard let (head,tail) = path.decompose else {
//         return trie.payload
//     }
//
//     switch head {
//     case .hop(_):
//         guard let subtrie = trie[head] else { return nil }
//         return extractUnifiables(subtrie, path:tail)
//     case .symbol("*"):
//         // collect everything
//         return Set(trie.tries.flatMap { $0.payload })
//
//     default:
//         // collect variable and exeact match
//
//         let variables = trie[.symbol("*")]?.payload
//
//         guard let exactly = trie[head] else {
//             return variables
//         }
//
//         guard var payload = extractUnifiables(exactly, path:tail) else {
//             return variables
//         }
//
//
//         if variables != nil {
//             payload.formUnion(variables!)
//         }
//         return payload
//
//     }
// }


/// extract exact path matches
// func extractVariants<T:TrieType where T.Leap==SymHop<String>, T.Value:Hashable>(_ trie:T, path:[T.Leap]) -> Set<T.Value>? {
//     guard let (head,tail) = path.decompose else {
//         return trie.payload
//     }
//
//     guard let subtrie = trie[head] else { return nil }
//
//     return extractVariants(subtrie, path:tail)
// }

// private func candidates<T:TrieType, N:Node where T.Leap==SymHop<String>, T.Value:Hashable, N.Symbol==String>(
//     _ indexed:T,
//     queryTerm:N,
//     extract:(T, path:[T.Leap]) -> Set<T.Value>?
//
//     ) -> Set<T.Value>? {
//
//     guard let (first,tail) = queryTerm.paths.decompose else { return nil }
//
//     guard var result = extract(indexed, path: first) else { return nil }
//
//     for path in tail {
//         guard let next = extract(indexed, path:path) else { return nil }
//         result.formIntersection(next)
//     }
//     return result
// }

// func candidateComplementaries<T:TrieType, N:Node where T.Leap==SymHop<N.Symbol>, T.Value:Hashable, N.Symbol==String>(_ indexed:T, term:N) -> Set<T.Value>? {
//     var queryTerm: N
//     switch term.symbol {
//     case "~":
//         queryTerm = term.nodes!.first!
//     case "!=":
//         queryTerm = N(symbol: "=", nodes: term.nodes)
//     case "=":
//         queryTerm = N(symbol:"!=", nodes: term.nodes)
//     default:
//         queryTerm = N(symbol:"~", nodes: [term])
//     }
//     return candidates(indexed, queryTerm:queryTerm) { a,b in extractUnifiables(a,path:b) }
// }

// func candidateVariants<T:TrieType, N:Node where T.Leap==SymHop<String>, T.Value:Hashable, N.Symbol==String>(_ indexed:T, term:N) -> Set<T.Value>? {
//     return candidates(indexed, queryTerm:term) { a,b in extractVariants(a,path:b) }
// }
