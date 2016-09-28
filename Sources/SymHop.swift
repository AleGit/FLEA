/// Data structure to build path indices for terms.
/// f(a,g(b)) has two paths from root to its two leaves.
/// - f@ε, a@1 ->  ε.f.1.a -> f.1.a -> symbol(f),hop(1),symbol(a)
/// - f@ε, g@1 -> b@1.1 -> f.2.g.1.b
enum SymHop<S:Hashable> {
  case symbol(S)
  case hop(Int)
}

extension SymHop: Hashable {
  /// Enable SymHop as element of sets.
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
  /// Enable pretty printing
  var description: String {
    switch self {
      case let .symbol(symbol):
        return "\(symbol)"
      case let .hop(hop):
        return "\(hop)"
    }
  }
}

/// Make SymHop equatable.
func ==<S: Hashable>(lhs: SymHop<S>, rhs: SymHop<S>) -> Bool {
  switch(lhs, rhs) {
    case let (.symbol(lsymbol), .symbol(rsymbol)):
      return lsymbol == rsymbol
    case let (.hop(lhop), .hop(rhop)):
      return lhop == rhop
    default:
      return false
  }
}
