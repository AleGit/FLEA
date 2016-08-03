enum SymHop<S:Hashable> {
    case symbol(S)
    case hop(Int)
}

extension SymHop: Hashable {
    var hashValue : Int {
        switch self {
        case let .symbol(symbol):
            return symbol.hashValue
        case let .hop(hop):
            return hop.hashValue
        }
    }
}

extension SymHop : CustomStringConvertible {
    var description : String {
        switch self {
        case let .symbol(symbol):
            return "\(symbol)"
        case let .hop(hop):
            return "\(hop)"
        }
    }
}

func ==<S:Hashable>(lhs:SymHop<S>, rhs:SymHop<S>) -> Bool {
    switch(lhs,rhs) {
    case let (.symbol(lsymbol), .symbol(rsymbol)):
        return lsymbol == rsymbol
    case let (.hop(lhop), .hop(rhop)):
        return lhop == rhop
    default:
        return false
    }
}
