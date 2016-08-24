//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation
/*
#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif
*/

extension Collection where Iterator.Element == SubSequence.Iterator.Element {
  /// Split a collection in a pair of its first element and the remaining elements.
  ///
  /// - [] -> nil
  /// - [a,...] -> (a,[...])
  ///
  /// _Complexity_: O(1) -- `first` and `dropFirst()` are O(1) for collections
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
  func containsOne<S:Sequence>(_ strings:S) -> Bool 
  where S.Iterator.Element == String {
    return strings.reduce(false) { $0 || self.contains($1) }
  }
  /// check if all members of a sequence are substrings of the string
  func containsAll<S:Sequence>(_ strings:S) -> Bool 
  where S.Iterator.Element == String {
    return strings.reduce(true) { $0 && self.contains($1) }
  }
}

// MARK: - utile iterator and sequence /* ******************* */

struct UtileIterator<S,T> : IteratorProtocol {
    private var this : S?
    private let step : (S) -> S?
    private let data : (S) -> T
    private let predicate : (S) -> Bool


    /// a iterator may outlive its creator, hence the functions `step`, `predicate`, and `data` may escape their context.
    init(first:S?, step:@escaping (S)->S?, where predicate:@escaping (S)->Bool = { _ in true }, data:@escaping (S)->T) {
        self.this = first
        self.step = step
        self.data = data
        self.predicate = predicate
    }

    mutating func next() -> T? {
        while let current = self.this {
          self.this = step(current)

          if predicate(current) {
            return data(current)
          }
        }

        return nil
    }
}

struct UtileSequence<S,T> : Sequence {
    private let this : S?
    private let step : (S) -> S?
    private let predicate : (S) -> Bool
    private let data : (S) -> T

    /// a sequence may outlive its creator, hence the functions `step`, `predicate`, and `data` may escape their context.
    init(first:S?, step:@escaping (S)->S?, where predicate: @escaping (S)->Bool = { _ in true }, data: @escaping (S)->T) {
        self.this = first
        self.step = step
        self.predicate = predicate
        self.data = data
    }

    func makeIterator() -> UtileIterator<S,T> {
        return UtileIterator(first: this, step: step, where:predicate, data: data)
    }

}

// MARK: - utile time functions /* ************************** */


/// Substitute for CFAbsoluteTime which does not seem to be available on Linux.
public typealias AbsoluteTime = Double

/// Substitute for CFAbsoluteTimeGetCurrent() which does not seem to be available on Linux.
func AbsoluteTimeGetCurrent() -> AbsoluteTime {
  var atime = timeval()             // initialize C struct
  let _ = gettimeofday(&atime,nil)  // will return 0
  return AbsoluteTime(atime.tv_sec) // s + µs
  + AbsoluteTime(atime.tv_usec)/AbsoluteTime(1_000_000.0)
}

public typealias UtileTimes = (user:Double,system:Double,absolute:AbsoluteTime)

private func ticksPerSecond() -> Double {
  return Double(sysconf(Int32(_SC_CLK_TCK)))
}

private func UtileTimesGetCurrent() -> UtileTimes {
  var ptime = tms()
  let _ = times(&ptime)

  return (
    user:Double(ptime.tms_utime)/ticksPerSecond(),
    system:Double(ptime.tms_stime)/ticksPerSecond(),
    absolute: AbsoluteTimeGetCurrent()
  )
}

func loggingTime() -> String {
  var t = time(nil) // : time_t 
  let tm = localtime(&t) // : struct tm *
  var s: Array<CChar> = Array(repeating: 0, count:64) // : char s[64];
  strftime(&s, s.count, "%F %T %z", tm);
  return String(cString:s)
}

private func -(lhs:UtileTimes, rhs:UtileTimes) -> UtileTimes {
  return (
    user:lhs.user-rhs.user,
    system:lhs.system-rhs.system,
    absolute:lhs.absolute-rhs.absolute
  )
}

/// Measure the absolute runtime of a code block.
/// Usage: `let (result,runtime) = measure { *code to measure* }`
public func utileMeasure<R>(f:()->R) -> (R, UtileTimes) {
  let start = UtileTimesGetCurrent()
  let result = f()
  let end = UtileTimesGetCurrent()
  return (result, end - start)
}


