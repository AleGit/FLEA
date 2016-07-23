@testable import FLEA

final class Instantiator<N:Node> : Substitution {
  private(set) var storage = [N:N]()

  subscript(key:N) -> N? {
    get { return storage[key] }
    set { storage[key] = newValue }
  }

  convenience init(dictionaryLiteral elements: (N, N)...) {
    self.init()
    for (key, value) in elements {
      self.storage[key] = value
    }
  }

  convenience init(dictionary: [N:N]) {
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

  func clean() {
    let keys = storage.filter { $0.0 == $0.1 }.map { $0.0 }
    for key in keys {
      storage.removeValue(forKey:key)
    }
  }
}

func ==<N:Node>(lhs:Instantiator<N>, rhs:Instantiator<N>) -> Bool {
  return lhs.storage == rhs.storage
}
