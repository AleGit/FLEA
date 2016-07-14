import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif


/// Substitute for CFAbsoluteTime which does not seem to be available on Linux.
typealias UtileAbsoluteTime = Double

/// Substitute for CFAbsoluteTimeGetCurrent() which does not seem to be available on Linux.
func UtileAbsoluteTimeGetCurrent() -> UtileAbsoluteTime {
  var tval = timeval()                                              // C struct
  let _ = gettimeofday(&tval,nil)                                   // will return 0
  return Double(tval.tv_sec) + Double(tval.tv_usec)/1_000_000.0     // s + µs
}

/// Measure the absolute runtime of a code block.
/// Usage: `let (result,runtime) = measure { *code to measure* }`
func measure<R>(f:()->R) -> (R, UtileAbsoluteTime) {
  let start = UtileAbsoluteTimeGetCurrent()
  let result = f()
  return (result, UtileAbsoluteTimeGetCurrent() - start)
}

struct UtileIterator<S,T> : IteratorProtocol {
    private var this : S?
    private let step : (S) -> S?
    private let data : (S) -> T
    private let predicate : (S) -> Bool

    init(first:S?, step:(S)->S?, where predicate:(S)->Bool = { _ in true }, data:(S)->T) {
        self.this = first
        self.step = step
        self.data = data
        self.predicate = predicate
    }

    mutating func next() -> T? {
        while let current = self.this {
          self.this = step(current)

          if let next = self.this where predicate(next) {
            return data(next)
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

    init(first:S?, step:(S)->S?, where predicate:(S)->Bool = { _ in true }, data:(S)->T) {
        self.this = first
        self.step = step
        self.predicate = predicate
        self.data = data
    }

    func makeIterator() -> UtileIterator<S,T> {
        return UtileIterator(first: this, step: step, where:predicate, data: data)
    }

}
