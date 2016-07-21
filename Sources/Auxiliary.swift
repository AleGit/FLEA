//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

extension Collection
where Iterator.Element == SubSequence.Iterator.Element {
    var decompose: (head: Iterator.Element, tail: [Iterator.Element])? {
        guard let head = first else { return nil }
        return (head, Array(dropFirst()))
    }
}
