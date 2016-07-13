import Foundation

struct FleaIterator<S,T> : IteratorProtocol {
    private var this : S?
    private let step : (S) -> S?
    private let data : (S) -> T

    init(first:S?, step:(S)->S?, data:(S)->T) {
        self.this = first
        self.step = step
        self.data = data
    }

    mutating func next() -> T? {
        guard let current = self.this else {
            return nil
        }
        self.this = self.step(current)
        return self.data(current)
    }
}

struct FleaSequence<S,T> : Sequence {
    private let this : S?
    private let step : (S) -> S?
    private let data : (S) -> T

    init(first:S?, step:(S)->S?, data:(S)->T) {
        self.this = first
        self.step = step
        self.data = data
    }

    func makeIterator() -> FleaIterator<S,T> {
        return FleaIterator(first: this, step: step, data: data)
    }

}
