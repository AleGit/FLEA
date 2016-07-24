///
protocol Substitution : DictionaryLiteralConvertible, Sequence, CustomStringConvertible
{
  associatedtype K : Hashable
  associatedtype V

    subscript (key:K) -> V? { get set }

    func makeIterator() -> DictionaryIterator<K, V>

    init(dictionary:[K:V])
}

/// A dictionary is a substitution.
extension Dictionary : Substitution {
  init(dictionary:[Key:Value]) {
    self = dictionary
  }
}

/// default implementation for substitutions
// extension Substitution where K : Node, V: Node {
//   var description : String {
//     let array = self.map{ "\($0)" }.joined(separator:",")
//     return "{\(array)}"
//   }
// }

/// 't * σ' returns the substitution of term t with σ.
func *<N:Node, S:Substitution where N == S.K, N == S.V>(t:N, σ:S) -> N {
    // assert(σ.isSubstitution)
    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes
    else { return t } // t is a variable not in σ or has no children

    return N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}


/// concationation of substitutions (specialized for Substitution)
func *<N:Node, S:Substitution where S.K==N,S.V==N>(lhs:S,rhs:S) -> S? {
  var subs = S()
  var lit = lhs.makeIterator()
  while let (key,value) = lit.next() {
    subs[key] = value * rhs
  }
  var rit = rhs.makeIterator()
  while let (key,value) = rit.next() {
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
  return subs
}
