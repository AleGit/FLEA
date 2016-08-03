import Foundation

protocol Trie {
    associatedtype Leap
    associatedtype Value
    associatedtype LeapS : Sequence // a sequence of leaps is a path, i.e. key
    associatedtype ValueS : Sequence // a sequence of stored values
    associatedtype TrieS : Sequence // a sequence of (sub)tries

    /// creates empty trie type
    init()

    /// creates a trie with one value at path.
    init<C:Collection where C.Iterator.Element == Leap,
        C.SubSequence.Iterator.Element == Leap>(with:Value, at:C)

    /// inserts one value at Leap path
    mutating func insert<C:Collection where C.Iterator.Element == Leap,
        C.SubSequence.Iterator.Element == Leap>(_ value:Value, at: C)

    /// deletes and returns one value at Leap path,
    /// if path or value do not exist trie stays unchanged and nil is returned
    mutating func delete<C:Collection where C.Iterator.Element == Leap,
        C.SubSequence.Iterator.Element == Leap>(_ value:Value, at: C) -> Value?

    /// returns all values at path
    func retrieve<C:Collection where C.Iterator.Element == Leap,
        C.SubSequence.Iterator.Element == Leap>(from:C) -> ValueS?

    /// stores one value at trie node
    mutating func insert(_ newMember:Value) -> (inserted:Bool, memberAfterInsert:Value)

    /// deletes and returns one value from trie node
    mutating func delete(_ value:Value) -> Value?

    /// get values at one trie node
    var values : ValueS? { get }

    var leaps : LeapS? { get }

    /// get (or set) subnode with step
    subscript(step:Leap) -> Self? { get set }

    /// get all immediate subtries
    var tries : TrieS? { get }

    /// get all values of a trie and all it's subtries
    /// var payload : ValueS? { get }
}

// MARK: default implementations for init, insert, delete, retrieve

extension Trie {

  /// Create a new trie with one value at path.
  init<C:Collection where C.Iterator.Element == Leap,
  C.SubSequence.Iterator.Element == Leap>(with value:Value, at path:C) {
    self.init() // initialize trie
    self.insert(value, at:path)
  }

  /// Inserts value at path. Possibly missing subtrie is created.
  mutating func insert<C:Collection where C.Iterator.Element == Leap,
  C.SubSequence.Iterator.Element == Leap>(_ value:Value, at path:C) {
    guard let (head,tail) = path.decompose else {
      self.insert(value)
      return
    }

    if self[head] == nil {
      self[head] = Self(with:value,at:tail)
    }
    else {
      self[head]!.insert(value, at:tail)
    }
  }

  /// Delete value at path. Returns deleted value or nil
  /// if path does not exist or value was not stored at path.
  /// Empty subtries are removed.
  mutating func delete<C:Collection where C.Iterator.Element == Leap,
  C.SubSequence.Iterator.Element == Leap>(_ value:Value, at path:C) -> Value? {
    guard let (head,tail) = path.decompose else {
      return self.delete(value)
    }
    guard var trie = self[head] else { return nil }
    let v = trie.delete(value, at:tail)
    self[head] = trie.isEmpty ? nil : trie
    return v
  }

  /// Returns values at path or nil if path does not exist.
  func retrieve<C:Collection where C.Iterator.Element == Leap,
  C.SubSequence.Iterator.Element == Leap>(from path:C) -> ValueS? {
    guard let (head,tail) = path.decompose else {
      return values
    }
    guard let trie = self[head] else { return nil }
    return trie.retrieve(from:tail)
  }
}

extension Trie {
  /// Returns subtrie at path or nil if path does not exist.
  subscript(path:[Leap]) -> Self? {
    guard let (head,tail) = path.decompose else { return self }

    guard let trie = self[head] else { return nil }

    return trie[tail]
  }

  /// _Complexity_: O(1)
  var isEmpty : Bool {
    guard var iv = self.values?.makeIterator(), iv.next() == nil else {
      // There are values, hence the trie is not empty.
      return false
    }
    guard var it = self.tries?.makeIterator(), it.next() == nil else {
      // There are subtries, hence the trie is not empty.
      // _This only holds, if there are no emtpy subtries._
      return false
    }

    // There are neither values nor subtries, hence the trie is empty.
    return true
  }
}



func ==<T:Trie where T.Value:Hashable, T.Leap:Hashable,
T.ValueS == Set<T.Value>, T.LeapS == Set<T.Leap>>(lhs:T,rhs:T) -> Bool {
  guard lhs.values == rhs.values else { return false }
  guard lhs.leaps == rhs.leaps else { return false }

  guard let leaps = lhs.leaps else {
    assert(rhs.leaps == nil)

    // no leaps at all
    return true
  }

  for leap in leaps {
    guard let l = lhs[leap], let r = rhs[leap], l==r else {
      return false
    }
  }

  return true
}

// MARK: - concrete trie types

// MARK: a value type trie

struct TrieStruct<K: Hashable, V: Hashable> {
  typealias Key = K
  typealias Value = V
  private var trieStore = [Key: TrieStruct<Key, Value>]()
  private var valueStore = Set<Value>()

  init() {    }
}

extension TrieStruct : Trie, Equatable {

  mutating func insert(_ newMember: Value) -> (inserted:Bool, memberAfterInsert:Value) {
      return valueStore.insert(newMember)
  }

  mutating func delete(_ value: Value) -> Value? {
      return valueStore.remove(value)
  }

  subscript(key:Key) -> TrieStruct? {
      get { return trieStore[key] }
      set { trieStore[key] = newValue }
  }

  var values : Set<Value>? {
      return self.valueStore
  }

  var leaps : Set<Key>? {
    return Set(self.trieStore.keys)
  }

  var tries : [TrieStruct]? {
      let ts = trieStore.values
      return Array(ts)
  }
}

// MARK: a reference type trie

final class TrieClass<K: Hashable, V: Hashable> {
  typealias Key = K
  typealias Value = V
  private var trieStore = [Key: TrieClass<Key, Value>]()
  private var valueStore = Set<Value>()

  init() {    }
}

extension TrieClass : Trie, Equatable {

  func insert(_ newMember: Value) -> (inserted:Bool, memberAfterInsert:Value) {
      return valueStore.insert(newMember)
  }

  func delete(_ value: Value) -> Value? {
      return valueStore.remove(value)
  }

  subscript(key:Key) -> TrieClass? {
      get { return trieStore[key] }
      set { trieStore[key] = newValue }
  }

  var values : Set<Value>? {
      return self.valueStore
  }

  var leaps : Set<Key>? {
    return Set(self.trieStore.keys)
  }

  var tries : [TrieClass]? {
      let ts = trieStore.values
      return Array(ts)
  }
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
