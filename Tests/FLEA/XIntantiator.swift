@testable import FLEA

final class Instantiator<N:Node> : Substitution, Equatable {
// struct Instantiator<N:Node> : Substitution, Equatable {
  private(set) var storage = [N:N]()

  subscript(key:N) -> N? {
    get { return storage[key] }
    set { storage[key] = newValue }
  }

  convenience
  init(dictionaryLiteral elements: (N, N)...) {
    // print("\(#function):\(elements)")
    self.init()
    for (key, value) in elements {
      self.storage[key] = value
    }
  }

  convenience
  init(dictionary: [N:N]) {
    // print("\(#function):\(dictionary)")
    self.init()
    self.storage = dictionary
  }

  func makeIterator() -> DictionaryIterator<N, N> {
    return storage.makeIterator()
  }

  var description : String {
    let pairs = self.map { "\($0)->\($1)"  }.joined(separator:",")
    return "{\(pairs)}"
  }

  // mutating
  func clean() {
    let keys = storage.filter { $0.0 == $0.1 }.map { $0.0 }
    for key in keys {
      storage.removeValue(forKey:key)
    }
  }
}

func ==<N:Node>(lhs:Instantiator<N>, rhs:Instantiator<N>) -> Bool {
  if lhs.storage != rhs.storage {
    print(lhs.storage.dynamicType,rhs.storage.dynamicType)
    print(lhs.dynamicType, rhs.dynamicType)
    print("\(#function) \(lhs.storage) \(rhs.storage)")

    let lkeys = Set(lhs.storage.keys)
    let rkeys = Set(rhs.storage.keys)
    print(lkeys, lkeys == rkeys, rkeys)

    for key in lkeys {
      let lvalue = lhs[key]!
        let rvalue = rhs[key]!
        if lvalue != rvalue {

          print(key,lvalue,rvalue,lvalue == rvalue)

          print(lvalue.hashValue, rvalue.hashValue)
          print(lvalue.dynamicType, rvalue.dynamicType)


        }
    }

  }
  return lhs.storage == rhs.storage
}
