//  Copyright © 2017 Alexander Maringele. All rights reserved.

import Foundation

extension Collection {
    /// Split a collection in a pair of its first element and the remaining elements.
    ///
    /// - [] -> nil
    /// - [a,...] -> (a,[...])
    ///
    /// _Complexity_: O(1) -- `first` and `dropFirst()` are O(1) for collections
    var decomposing: (head: Self.Element, tail: Self.SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst()) //
    }
}

extension Sequence {
    /// check if a predicate holds for all members of a sequence
    func all(_ predicate: (Element) -> Bool) -> Bool {
        return reduce(true) { $0 && predicate($1) }
    }

    /// check if a predicate holds for at least one member of a sequence
    func one(_ predicate: (Element) -> Bool) -> Bool {
        return reduce(false) { $0 || predicate($1) }
    }

    /// count the members of a sequence where a predicate holds
    func count(_ predicate: (Element) -> Bool = { _ in true }) -> Int {
        return reduce(0) { $0 + (predicate($1) ? 1 : 0) }
    }
}

/* postbone after talk */
typealias MultiSet<T: Hashable> = [T: Int]

/* postbone after talk */
extension Sequence where Element: Hashable {
    var multiSet: MultiSet<Element> {
        var d = MultiSet<Element>()
        for element in self {
            d[element] = (d[element] ?? 0) + 1
        }
        return d
    }
}

extension String {
    /// check if the string has an uppercase character at given index.
    // swiftlint:disable variable_name
    func isUppercased(at: Index) -> Bool {
        // swiftlint:enable variable_name

        let range = at ..< index(after: at)
        return rangeOfCharacter(from: .uppercaseLetters, options: [], range: range) != nil
    }
}

extension String {
    /// check if at least on member of a sequence is a substring of the string
    func containsOne<S: Sequence>(_ strings: S) -> Bool
        where S.Element == String {
        return strings.reduce(false) { $0 || self.contains($1) }
    }

    /// check if all members of a sequence are substrings of the string
    func containsAll<S: Sequence>(_ strings: S) -> Bool
        where S.Element == String {
        return strings.reduce(true) { $0 && self.contains($1) }
    }
}

// MARK: - utile iterator and sequence /* ******************* */

struct UtileIterator<S, T>: IteratorProtocol {
    private var this: S?
    private let step: (S) -> S?
    private let data: (S) -> T
    private let predicate: (S) -> Bool

    /// a iterator may outlive its creator,
    /// hence the functions `step`, `predicate`, and `data` may escape their context.
    init(first: S?, step: @escaping (S) -> S?, where
        predicate: @escaping (S) -> Bool = { _ in true }, data: @escaping (S) -> T) {
        this = first
        self.step = step
        self.data = data
        self.predicate = predicate
    }

    mutating func next() -> T? {
        while let current = self.this {
            this = step(current)

            if predicate(current) {
                return data(current)
            }
        }

        return nil
    }
}

struct UtileSequence<S, T>: Sequence {
    private let this: S?
    private let step: (S) -> S?
    private let predicate: (S) -> Bool
    private let data: (S) -> T

    /// a sequence may outlive its creator,
    /// hence the functions `step`, `predicate`, and `data` may escape their context.
    init(first: S?, step: @escaping (S) -> S?, where
        predicate: @escaping (S) -> Bool = { _ in true }, data: @escaping (S) -> T) {
        this = first
        self.step = step
        self.predicate = predicate
        self.data = data
    }

    func makeIterator() -> UtileIterator<S, T> {
        return UtileIterator(first: this, step: step, where: predicate, data: data)
    }
}

// MARK: - utile time functions /* ************************** */

/// Substitute for CFAbsoluteTime which does not seem to be available on Linux.
public typealias AbsoluteTime = Double
public typealias TimeInterval = Double

/// Substitute for CFAbsoluteTimeGetCurrent() which does not seem to be available on Linux.
func AbsoluteTimeGetCurrent() -> AbsoluteTime {
    var atime = timeval() // initialize C struct
    _ = gettimeofday(&atime, nil) // will return 0
    return AbsoluteTime(atime.tv_sec) // s + µs
        + AbsoluteTime(atime.tv_usec) / AbsoluteTime(1_000_000.0)
}

public typealias UtileTimes = (user: Double, system: Double, absolute: AbsoluteTime)

private func ticksPerSecond() -> Double {
    return Double(sysconf(Int32(_SC_CLK_TCK)))
}

private func UtileTimesGetCurrent() -> UtileTimes {
    var ptime = tms()
    _ = times(&ptime)

    return (
        user: Double(ptime.tms_utime) / ticksPerSecond(),
        system: Double(ptime.tms_stime) / ticksPerSecond(),
        absolute: AbsoluteTimeGetCurrent()
    )
}

private func - (lhs: UtileTimes, rhs: UtileTimes) -> UtileTimes {
    return (
        user: lhs.user - rhs.user,
        system: lhs.system - rhs.system,
        absolute: lhs.absolute - rhs.absolute
    )
}

/// Measure the absolute runtime of a code block.
/// Usage: `let (result,runtime) = measure { *code to measure* }`
// swiftlint:disable variable_name
public func utileMeasure<R>(f: () -> R) -> (R, UtileTimes) {
    // swiftlint:enable variable_name
    let start = UtileTimesGetCurrent()
    let result = f()
    let end = UtileTimesGetCurrent()
    return (result, end - start)
}
