import Foundation

struct FleaIterator<S,T> : IteratorProtocol {
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

struct FleaSequence<S,T> : Sequence {
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

    func makeIterator() -> FleaIterator<S,T> {
        return FleaIterator(first: this, step: step, where:predicate, data: data)
    }

}
