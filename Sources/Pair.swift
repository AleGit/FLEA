

struct Pair<T: Hashable, U: Hashable>: Hashable, CustomStringConvertible {
    let values: (T, U)

    var hashValue: Int {
        let (first, second) = values
        return first.hashValue &* 31 &+ second.hashValue
    }

    init(_ first: T, _ second: U) {
        values = (first, second)
    }

    var description: String {
        return "\(values)"
    }

    static func ==(lhs: Pair, rhs: Pair) -> Bool {
        return lhs.values == rhs.values
    }
}