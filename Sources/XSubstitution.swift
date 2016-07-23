

protocol Substitution : DictionaryLiteralConvertible, Sequence,
CustomStringConvertible
{
  associatedtype K : Hashable
  associatedtype V


    subscript (key:K) -> V? { get set }

    func makeIterator() -> DictionaryIterator<K, V>

    init(dictionary:[K:V])
    // init(dictionary:[N.Symbol:N])
    // init(dictionary:[N.Symbol:N.Symbol])
    // init(array:[(N,N)])

    mutating func clean()

}

extension Dictionary : Substitution {
  init(dictionary:[Key:Value]) {
    self = dictionary
  }
  mutating func clean() {
    // nothing to do
  }
}

/// 't * σ' returns the substitution of term t with σ.
func *<N:Node, S:Substitution where N == S.K, N == S.V>(t:N, σ:S) -> N {
    // assert(σ.isSubstitution)
    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes
    else { return t } // t is a variable not in σ or has no children

    return N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}

func *<N:Node, S:Substitution where S.K==N,S.V==N>(lhs:S,rhs:S) -> S? {
  var subs = S()
  // for (key,value) in lhs {
  //   subs[key] = value * rhs
  // }
  var lit = lhs.makeIterator()
  while let (key,value) = lit.next() {
    subs[key] = value * rhs
  }
  // for (key,value) in rhs {
  //   if let term = subs[key] {
  //     guard term == value else {
  //       return nil
  //     }
  //   }
  //   else {
  //     subs[key] = value
  //   }
  // }
  var rit = rhs.makeIterator()
  while let (key,value) = rit.next() {
    if let term = subs[key] {
      guard term == value else {
        return nil
      }
    }
    else {
      subs[key] = value
    }
  }
  return subs
}
