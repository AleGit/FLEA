//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

extension Collection
where Iterator.Element == SubSequence.Iterator.Element {
    var decompose: (head: Iterator.Element, tail: [Iterator.Element])? {
        guard let head = first else { return nil }
        return (head, Array(dropFirst()))
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
