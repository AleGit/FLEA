protocol Substitution : DictionaryLiteralConvertible, Sequence {
  associatedtype N : Node

  subscript (key:N) -> N? { get set }
}

final class Instantiator<N:Node> :  FLEA.Substitution {
  private(set) var storage = [N:N]()

  subscript(key:N) -> N?{
    get { return storage[key] }
    set { storage[key] = newValue }
  }

  convenience init(dictionaryLiteral elements: (N, N)...) {
        self.init()
        for (key, value) in elements {
            self.storage[key] = value
        }
    }

    func makeIterator() -> DictionaryIterator<N, N> {
      return storage.makeIterator()
    }
}



/// 't * σ' returns the substitution of term t with σ.

func *<S:Substitution>(t:S.N, σ:S) -> S.N {
    // assert(σ.isSubstitution)

    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes where nodes.count > 0
    else { return t } // t is a variable not in σ or has not children

    return S.N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}
