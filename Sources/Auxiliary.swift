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
        let range = at..<self.index(after: at)
        return self.rangeOfCharacter(from: .uppercaseLetters, options: [], range: range) != nil
    }
}

extension Character {
    var isUppercase: Bool {
      let str = String(self)
      return str.isUppercased(at: str.startIndex)
    }
}
