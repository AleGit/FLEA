/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// 't * σ' returns the application of substitution σ on term t.
func *<N:Node>(t:N, σ:[N:N]) -> N {
  Syslog.debug { "DictionarySubstitution" }
    assert(σ.isSubstitution)

    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes where nodes.count > 0
    else { return t } // t is a variable not in σ or has not children

    return N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}

/// concationation of substitutions (specialized for Dictionary)
func *<N:Node>(lhs:[N:N], rhs:[N:N]) -> [N:N]? {
  var subs = [N:N]()

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

/// A node dictionary has a specialized description.
extension Dictionary where Key:Node, Value:Node {
  var description : String {
    let pairs = self.map { "\($0)->\($1)"  }.joined(separator:",")
    return "{\(pairs)}"
  }
}
