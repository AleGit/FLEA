/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// A substitution is a assignment from variables to terms.
protocol Substitution : ExpressibleByDictionaryLiteral, Sequence, CustomStringConvertible
{
  associatedtype K : Hashable
  associatedtype V

    subscript (key:K) -> V? { get set }

    init(dictionary:[K:V])
}

/// A dictionary is a substitution.
extension Dictionary : Substitution {
  init(dictionary:[Key:Value]) {
    self = dictionary
  }
}

/// 't * σ' returns the application of substitution σ on term t.
func *<N:Node, S:Substitution>(t:N, σ:S) -> N 
where N == S.K, N == S.V, S.Iterator == DictionaryIterator<N,N> { 

    // assert(σ.isSubstitution)
    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes
    else { return t } // t is a variable not in σ or has no children

    return N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}


/// concationation of substitutions (specialized for Substitution)
func *<N:Node, S:Substitution>(lhs:S,rhs:S) -> S? 
where S.K==N,S.V==N, S.Iterator==DictionaryIterator<N,N> {

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
  return subs
}
