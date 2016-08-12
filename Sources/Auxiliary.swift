//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

extension Collection where Iterator.Element == SubSequence.Iterator.Element {
  /// Split a collection in a pair of its first element and the remaining elements.
  ///
  /// - [] -> nil
  /// - [a,...] -> (a,[...])
  ///
  /// _Complexity_: O(1) -- `first` and `dropFirst()` are O(1) for collection
  var decomposing: (head: Self.Iterator.Element, tail: Self.SubSequence)? {
    guard let head = first else { return nil }
    return (head, dropFirst()) //
  }
}

extension Sequence {
  /// check if a predicate holds for all members of a sequence
  func all(_ predicate: (Iterator.Element) -> Bool) -> Bool {
    return self.reduce(true) { $0 && predicate($1) }
  }

  /// check if a predicate holds for at least one member of a sequence
  func one(_ predicate: (Iterator.Element) -> Bool) -> Bool {
    return self.reduce(false) { $0 || predicate($1) }
  }

  /// count the members of a sequence where a predicate holds
  func count(_ predicate: (Iterator.Element) -> Bool = { _ in true }) -> Int {
    return self.reduce(0) { $0 + (predicate($1) ? 1 : 0) }
  }
}

extension String {
  /// check if the string has an uppercase character at given index.
  func isUppercased(at: Index) -> Bool {
    let range = at..<self.index(after: at)
    return self.rangeOfCharacter(from: .uppercaseLetters, options: [], range: range) != nil
  }
}

extension String  {
  /// check if at least on member of a sequence is a substring of the string
  func containsOne<S:Sequence where S.Iterator.Element == String>(_ strings:S) -> Bool {
    return strings.reduce(false) { $0 || self.contains($1) }
  }
  /// check if all members of a sequence are substrings of the string
  func containsAll<S:Sequence where S.Iterator.Element == String>(_ strings:S) -> Bool {
    return strings.reduce(true) { $0 && self.contains($1) }
  }
}
