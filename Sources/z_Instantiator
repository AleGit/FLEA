/// an implementation of Substitution (not in use yet)

final class Instantiator<N:Node> :  FLEA.Substitution {
  private(set) var storage = [N:N]()

  subscript(key:N) -> N?{
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
}

extension Instantiator : CustomStringConvertible {
  var description : String {
    let pairs = self.map { "\($0)->\($1)"  }.joined(separator:",")
    return "{\(pairs)}"
  }

}

extension Instantiator {
  func clean() {
    let keys = storage.filter { $0.0 == $0.1 }.map { $0.0 }
    for key in keys {
      storage.removeValue(forKey:key)
    }

  }
}
