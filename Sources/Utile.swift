
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
