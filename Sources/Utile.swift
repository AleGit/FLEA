import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

let ticksPerSecond = Double(sysconf(_SC_CLK_TCK))

/// Substitute for CFAbsoluteTime which does not seem to be available on Linux.
typealias UtileTime = (user:Double,system:Double,absolute:Double)

/// Substitute for CFAbsoluteTimeGetCurrent() which does not seem to be available on Linux.
func UtileTimeGetCurrent() -> UtileTime {
  var atime = timeval()                   // C struct
  var ptime = tms()                       //
  let _ = gettimeofday(&atime,nil)           // will return 0
  let _ = times(&ptime)


  return (
    user:Double(ptime.tms_utime)/ticksPerSecond,
    system:Double(ptime.tms_stime)/ticksPerSecond,
    absolute:Double(atime.tv_sec) + Double(atime.tv_usec)/1_000_000.0     // s + µs
  )
}

func -(lhs:UtileTime, rhs:UtileTime) -> UtileTime {
  return (
    user:lhs.user-rhs.user,
  system:lhs.system-rhs.system,
  absolute:lhs.absolute-rhs.absolute)
}

/// Measure the absolute runtime of a code block.
/// Usage: `let (result,runtime) = measure { *code to measure* }`
func measure<R>(f:()->R) -> (R, UtileTime) {
  let start = UtileTimeGetCurrent()
  let result = f()
  let end = UtileTimeGetCurrent()
  return (result, end - start)
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
