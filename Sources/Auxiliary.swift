//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

extension Collection
where Iterator.Element == SubSequence.Iterator.Element {

    var decomposing: (head: Self.Iterator.Element, tail: Self.SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
      }

}

extension Sequence {

    func all(_ predicate: (Iterator.Element) -> Bool) -> Bool {
        return self.reduce(true) { $0 && predicate($1) }
    }

    func one(_ predicate: (Iterator.Element) -> Bool) -> Bool {
        return self.reduce(false) { $0 || predicate($1) }
    }

    func count(_ predicate: (Iterator.Element) -> Bool = { _ in true }) -> Int {
        return self.reduce(0) { $0 + (predicate($1) ? 1 : 0) }
    }
}

extension String {
    func isUppercased(at: Index) -> Bool {
      #if os(OSX)
        let range = at..<self.index(after: at)
        return self.rangeOfCharacter(from: .uppercaseLetters, options: [], range: range) != nil
      #elseif os(Linux)
        let range = at..<self.index(after: at)
        return self.rangeOfCharacter(from: NSCharacterSet.uppercaseLetters(), options: [], range: range) != nil
      #endif
    }
}

extension String  {
    //    func contains(string:StringSymbol) -> Bool {
    //        return self.rangeOfString(string) != nil
    //    }
    func containsOne<S:Sequence where S.Iterator.Element == String>(_ strings:S) -> Bool {
        return strings.reduce(false) { $0 || self.contains($1) }
    }
    func containsAll<S:Sequence where S.Iterator.Element == String>(_ strings:S) -> Bool {
        return strings.reduce(true) { $0 && self.contains($1) }
    }
}

extension Character {
    var isUppercase: Bool {
      let str = String(self)
      return str.isUppercased(at: str.startIndex)
    }
}
