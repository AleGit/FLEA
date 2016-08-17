/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// A substitution is a mapping from keys to values, e.g. a dictionary.
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

/// A node substitution has a specialized description.
extension Substitution // K == V not necessary
where K:Node, V:Node, Iterator == DictionaryIterator<K,V> {
  var description : String {
    let pairs = self.map { "\($0)->\($1)"  }.joined(separator:",")
    return "{\(pairs)}"
  }
}

/// 't * σ' returns the application of substitution σ on term t.
/// *caution*: this implementation is more general as 
/// the usual definition of substitution, where only variables
/// are substituted with terms. Here any arbitrary subterm can be 
/// replaced with an other term.
func *<N:Node, S:Substitution>(t:N, σ:S) -> N 
where N == S.K, N == S.V, S.Iterator == DictionaryIterator<N,N> { 

    if let tσ = σ[t] { return tσ } // t is (variable or term) in σ.keys

    guard let nodes = t.nodes else {
      // t is a variable, but in in σ
      return N(variable:t.symbol) // no implicit sharing!
    }

    return N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}


/// concationation of substitutions
func *<N:Node, S:Substitution>(lhs:S,rhs:S) -> S? 
where N == S.K, N==S.V, S.Iterator==DictionaryIterator<N,N> {

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

/// 't * s' returns the substitution of all variables in t with term s.
func *<N:Node>(t:N, s:N) -> N {
    guard let nodes = t.nodes else { return s } // a variable

    return N(symbol:t.symbol, nodes: nodes.map { $0 * s })
}

/// 't⊥' returns the substitution of all variables in t with constant '⊥'.
postfix func ⊥<N:Node>(t:N) -> N 
where N:SymbolStringTyped {
    return t * N(c:"⊥")
}

/*
extension Dictionary where Key:Node, Value:Node { // , Key == Value does not work
    /// Do the runtime types of keys and values match?
    private var isHomogenous : Bool {
        return self.keys.first?.dynamicType == self.values.first?.dynamicType
    }

    /// Are *variables* mapped to terms?
    private var allKeysAreVariables : Bool {
        return Array(self.keys).reduce(true) {
            $0 && $1.nodes == nil
        }
    }

    /// Are terms mapped to *variables*?
    private var allValuesAreVariables : Bool {
        return Array(self.values).reduce(true) {
            $0 && $1.nodes == nil
        }
    }

    /// Are distinct terms mapped to *distinguishable* terms?
    private var isInjective : Bool {
        return self.keys.count == Set(self.values).count
    }

    /// A substitution maps variables to terms.
    var isSubstitution : Bool {
        return allKeysAreVariables
    }

    /// A variable substitution maps variables to variables.
    var isVariableSubstitution : Bool {
        return allKeysAreVariables && allValuesAreVariables
    }

    /// A (variable) renaming maps distinct variables to distinguishable variables.
    var isRenaming : Bool {
        return allKeysAreVariables && allValuesAreVariables && isInjective
    }
}

*/
