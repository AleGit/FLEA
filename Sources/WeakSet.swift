/// Unordered collection of weak references to hashable objects.
/// Created by Adam Preble on 2/19/15.
/// [WeakSet](https://gist.github.com/preble/13ab713ac044876c89b5)
/// Modified by Alexander Maringele 2016.
/// **Caution:** The collection may contain less entries than elements inserted.
/// When there is no strong reference to an weak entry's element, then
/// the entry does not count and will be removed eventually.
/// So even when it's immutable count can change between two calls.
struct WeakSet<T where T: AnyObject, T: Hashable, T:CustomStringConvertible> {
    private var contents = [Int: [WeakEntry<T>]](minimumCapacity:1)
    init(){}

}

/// A weak entry holds a weak reference to an hashable object.
/// [ARC](https://en.wikipedia.org/wiki/Automatic_Reference_Counting)
/// deallocates an object, when there is no strong reference left.
/// Additionally weak references to this object will be set to nil.
private struct WeakEntry<T where T: AnyObject, T: Hashable, T:CustomStringConvertible> {
    weak var element: T?
}

/// A protocol for collections with a subset of set algebra methods.
protocol PartialSetAlgebra {
  associatedtype Element
  mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
  func contains(_ member: Element) -> Bool
}

/// Trivially a set supports a subset of set algebra methods.
extension Set : PartialSetAlgebra {}

/// A marker protocol wor collection with weak references to objects.
protocol WeakPartialSetAlgebra : PartialSetAlgebra {}

/// A weak set is a collection of weak references
/// and supports a subset of set algebra methods.
extension WeakSet : WeakPartialSetAlgebra {

  /// Add an element (and get it's substitution).
  mutating func insert(_ newElement: T) -> (inserted: Bool, memberAfterInsert: T) {
    let value = newElement.hashValue

    guard let validEntries = entries(at: value) else {
      // no valid entry at all, create a new list with one element
      contents[value] = [WeakEntry(element:newElement)]
      return (true,newElement)
    }

    for entry in validEntries {
      if let element = entry.element, element == newElement {
        // newElement is allready in the collection,
        // hence return element from collection
        return (false,element)
      }
    }

    // the new element is not in the collection
    contents[value]?.append(WeakEntry(element:newElement))
    return (true,newElement)
  }

  /// Check if an object is in the collection.
  /// **Complexity:** O(1). *Worst case:* O(n) when all hash values collide.
  func contains(_ member: T) -> Bool {
    let value = member.hashValue
    guard let entries = contents[value] else {
      return false
    }
    for entry in entries {
      if let element = entry.element, element == member {
        return true
      }
    }
    return false
  }
}

///
extension WeakSet {
  /// Number of entries *with* a referenced object.
  /// This number can decrease even when the weak set is immutable.
  /// An atomic insert increases this number by one.
  /// *Complexity*: O(n)
  var count : Int {
    return contents.flatMap({$0.1}).filter { $0.element != nil}.count
  }

  /// Number of entries *without* a referenced object.
  /// This number can increase even when the weak set is immutable.
  /// An atomic insert can change this number by n ∊ [-nilCount,0].
  /// *Complexity*: O(n)
  var nilCount : Int {
    return contents.flatMap({$0.1}).filter { $0.element == nil}.count
  }

  /// Number of entries *with or without* a refernced object.
  /// This number can not change when the weak set is immutable
  /// and 'count + nilCount = totalCount' holds.
  /// An atomic insert can change this number by n ∊ [-nilCount,1].
  /// *Complexity*: O(n)
  var totalCount : Int {
    return contents.reduce(0) { $0 + $1.1.count }
  }

  /// Number of list of entries.
  /// This number can not change when the weak set is immutable
  /// and 'keyCount <= totalCount' holds.
  /// An atomic insert can change this number by n ∊ [-nilCount,1]
  /// O(1)
  var keyCount : Int {
    return contents.count
  }
}

// MARK: Iterator protocol and Sequence

/// The weak set type is it's own consuming iterator type.
extension WeakSet : IteratorProtocol {
  mutating func next() -> T? {
    guard let first = contents.first else { return nil }

    guard var entries = contents[first.0]?.filter({$0.element != nil}),
    entries.count > 0 else {
      // no valid entries at all
      contents[first.0] = nil
      return self.next()
    }

    defer {
      entries.removeLast()
      contents[first.0] = entries
    }

    guard let member = entries.last?.element else {
      // the last entry should hold a valid reference, but the
      /// weakly referenced object was deallocated after filtering
      Syslog.warning { "*** WeakSetInterator failed ***"}
      return next()
    }

    // now the object is strongly referenced

    return member
  }
}

// MARK: - Sequence

extension WeakSet : Sequence {
  func makeIterator() -> WeakSet<T> {
    return self // a consumable copy
  }
}

extension WeakSet :  ExpressibleByArrayLiteral {
  init(arrayLiteral: T...) {
    self.init()
    for element in arrayLiteral {
      let _ = self.insert(element)
    }
  }
}

extension WeakSet {
  init(set:Set<T>) {
    self.init()
    for s in set {
      let _ = self.insert(s)
    }
  }
}

// MARK: - Misc

extension WeakEntry : CustomStringConvertible {
  var description : String {
    guard let e = self.element else {
      return "nillified"
    }
    return e.description
  }
}



extension WeakSet {
  /// Update and return list of valid (not nullified) entries for a value
  private mutating func entries(at value: Int) -> [WeakEntry<T>]? {
    guard let count = contents[value]?.count else {
      // no entries at all
      return nil
    }

    guard let entries = contents[value]?.filter({$0.element != nil}),
    entries.count > 0 else {
        // invalid entries only
        contents[value] = nil
        return nil
      }

      if entries.count != count {
        // valid and invalid entries, hence cleanup
        contents[value] = entries
      }
      return entries
  }

  mutating func clean() {
    for key in contents.keys {
      let _ = entries(at:key)
    }
  }

  /// The number of extra members (values) per hash value (key)
  /// collision count <= count - contents.count when no member is nillified.
  /// collision count = count - contents.count when no member is nillified.
  var collisionCount : Int {
    return contents.filter({ $0.1.count > 1}).map({ $0.1 }).reduce(0) {
      $0 + $1.count - 1
    }
  }
}
