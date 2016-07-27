/// Idea by Adam Preble on 2/19/15.
/// [WeakSet](https://gist.github.com/preble/13ab713ac044876c89b5)

private struct WeakEntry<T where T: AnyObject, T: Hashable, T:CustomStringConvertible> {
    weak var element: T?
}

extension WeakEntry : CustomStringConvertible {
  var description : String {
    guard let e = self.element else {
      return "nillified"
    }
    return e.description
  }
}

struct WeakSetIterator<T where T: AnyObject, T: Hashable, T:CustomStringConvertible> : IteratorProtocol {
  private var contents : [Int : [WeakEntry<T>]]

  private init(contents:[Int : [WeakEntry<T>]]) {
    self.contents = contents
  }

  mutating func next() -> T? {
    guard let first = contents.first else { return nil }

    guard var entries = contents[first.0]?.filter({$0.element != nil})
    where entries.count > 0 else {
      // no valid entries at all
      contents[first.0] = nil
      return self.next()
    }

    guard let member = entries.last?.element else {
      Syslog.warning { "*** WeakSetInterator failed ***"}
      return nil
    }
    entries.removeLast()
    contents[first.0] = entries
    return member
  }
}

extension WeakSet : Sequence {
  func makeIterator() -> WeakSetIterator<T> {
    return WeakSetIterator(contents:self.contents)
  }
}

/// Weak, unordered collection of objects.
struct WeakSet<T where T: AnyObject, T: Hashable, T:CustomStringConvertible> {
    private var contents = [Int: [WeakEntry<T>]]()

    /// Add an element (and get it's substitution).
    mutating func insert(_ newElement: T) -> (inserted: Bool, memberAfterInsert: T) {
      let value = newElement.hashValue

      guard let validEntries = entries(at: value) else {
        // no valid entry at all
        contents[value] = [WeakEntry(element:newElement)]
        return (true,newElement)
      }

      for entry in validEntries {
        if let element = entry.element where element == newElement {
          // newElement is allready in the collection,
          // hence return element from collection
          return (false,element)
        }
      }

      // the new element is not in the collection
      contents[value]?.append(WeakEntry(element:newElement))
      return (true,newElement)
    }

    private mutating func entries(at hashValue: Int) -> [WeakEntry<T>]? {
      guard let count = contents[hashValue]?.count else {
        // no entries at all
        return nil
      }

      guard let entries = contents[hashValue]?.filter({$0.element != nil})
        where entries.count > 0 else {
          // invalid entries only
          contents[hashValue] = nil
          return nil
        }

        if entries.count != count {
          // valid and invalid entries, hence cleanup
          contents[hashValue] = entries
        }
        return entries
    }

    /// *Complexity*: O(n)
    var count : Int {
      return contents.flatMap({$0.1}).filter { $0.element != nil}.count
    }

    func contains(_ member: T) -> Bool {
      let value = member.hashValue
      guard let entries = contents[value] else {
        return false
      }
      for entry in entries {
        if let element = entry.element where element == member {
          return true
        }
      }
      return false

    }
}
