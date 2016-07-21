/// A replacement for [N:N] (not in use yet)
protocol Substitution : DictionaryLiteralConvertible, Sequence {
  associatedtype N : Node

  subscript (key:N) -> N? { get set }

  func makeIterator() -> DictionaryIterator<N, N>

  init(dictionary:[N:N])
  // init(dictionary:[N.Symbol:N])
  // init(dictionary:[N.Symbol:N.Symbol])
  // init(array:[(N,N)])

  mutating func clean()

}

/// 't * σ' returns the substitution of term t with σ.
func *<S:Substitution>(t:S.N, σ:S) -> S.N {
    // assert(σ.isSubstitution)

    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes where nodes.count > 0
    else { return t } // t is a variable not in σ or has not children

    return S.N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}

func *<S:Substitution>(lhs:S,rhs:S) -> S? { return nil }

func *<S:Substitution where S.Iterator.Element == (key:S.N,value:S.N)>(lhs:S, rhs:S) -> S? {
  var subs = S()

  for (key,value) in lhs {
    subs[key] = value * rhs
  }
  for (key,value) in rhs {
    if let term = subs[key] {
      // allready set
      guard term == value else {
        // and different
        return nil
      }
      // but equal
    }
    else {
      // not set yet
      subs[key] = value
    }
  }
  subs.clean()
  return subs
}
