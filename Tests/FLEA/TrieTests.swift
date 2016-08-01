import XCTest

@testable import FLEA

public class TrieTests : XCTestCase {
  static var allTests : [(String, (TrieTests) -> () throws -> Void)] {
    return [
    ("testNonFile", testBasics)
    ]
  }





  func testBasics() {
    XCTAssertTrue(true,nok)

    var mytrie = TrieStruct<Int,String>()

    XCTAssertTrue(mytrie.isEmpty,nok)

    mytrie.insert([1,4,5,6,7,8],value:"145678")
    mytrie.insert([1,4,5,6,1], value:"145678")

    let _ = mytrie.delete([1,4,5,6,1], value:"145678")

    XCTAssertFalse(mytrie.isEmpty,nok)

    let _ = mytrie.delete([1,4,5,6,7,8],value:"145678")

    XCTAssertTrue(mytrie.isEmpty,nok)

    print(mytrie)


  }


}

struct TrieStruct<K: Hashable, V: Hashable> {
  typealias Key = K
  typealias Value = V
  private var trieStore = [Key: TrieStruct<Key, Value>]()
  private var valueStore = Set<Value>()

  init() {    }
}

extension TrieStruct : Trie {

  mutating func insert(_ value: Value) {
      valueStore.insert(value)
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

  var tries : [TrieStruct]? {
      let ts = trieStore.values
      return Array(ts)
  }
}
//
// extension TrieStruct {
//   /// get valueStore of `self` and all its successors
//   var payload : Set<Value> {
//       var collected = valueStore
//       for (_,trie) in trieStore {
//           collected.formUnion(trie.payload)
//       }
//       return collected
//   }
// }
//
extension TrieStruct : Equatable {
  // var isEmpty: Bool {
  //   guard valueStore.isEmpty else { return false }
  //
  //
  //
  //
  //
  //   // return trieStore.reduce(valueStore.isEmpty) { $0 && $1.1.isEmpty }
  // }
}

func ==<K,V>(lhs:TrieStruct<K,V>, rhs:TrieStruct<K,V>) -> Bool {
  if lhs.valueStore == rhs.valueStore && lhs.trieStore == rhs.trieStore {
      return true
  }
  else {
      return false
  }
}
