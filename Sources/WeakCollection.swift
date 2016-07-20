/// Idea by Adam Preble on 2/19/15.
/// [WeakSet](https://gist.github.com/preble/13ab713ac044876c89b5)

private struct WeakEntry<T where T: AnyObject, T: Hashable> {
    weak var element: T?
}

/// Weak, unordered collection of objects.
struct WeakCollection<T where T: AnyObject, T: Hashable> {
    private var contents = [Int: [WeakEntry<T>]]()

    /// Add an element (and get it's substitution).
    mutating func insert(newElement: T) -> T {
      let value = newElement.hashValue

      guard let validEntries = entries(at: value) else {
        // no valid entry at all
        contents[value] = [WeakEntry(element:newElement)]
        return newElement
      }

      for entry in validEntries {
        if let element = entry.element where element == newElement {
          // newElement is allready in the collection,
          // hence return element from collection
          return element
        }
      }

      // the new element is not in the collection
      contents[value]?.append(WeakEntry(element:newElement))
      return newElement
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
          // valid and invalid entries
          contents[hashValue] = entries
        }
        return entries
    }

    var count : Int {
      let x = contents.flatMap({$0})
      print(x)
      return x.count
    }
}
