import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif


// func measure<R>(f:()->R) -> (R, CFTimeInterval){
//     let start = CFAbsoluteTimeGetCurrent()
//     return (f(), CFAbsoluteTimeGetCurrent()-start)
// }

func -(lhs:timeval, rhs:timeval) -> Double {
  let nsec = Double(lhs.tv_usec - rhs.tv_usec) / 1_000_000.0

  let result = Double( lhs.tv_sec - rhs.tv_sec) + nsec
  print(lhs,rhs,result)
  return result

}

func measure<R>(f:()->R) -> (R, Double) {
  var start = timeval()
  var end = timeval()

  let _ = gettimeofday(&start, nil)

  let result = f()
  let _ = gettimeofday(&end,nil)

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
