

/// 't * σ' applies substitution σ on term t.
func *<N:Node>(t:N, σ:[N:N]) -> N {
    assert(σ.isSubstitution)

    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys

    guard let nodes = t.nodes where nodes.count > 0
    else { return t } // t is a variable not in σ or has not children

    return N(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}


/// 't ** s' replaces all variables in t with term s.
func **<N:Node>(t:N, s:N) -> N {
    guard let nodes = t.nodes else { return s } // a variable

    return N(symbol:t.symbol, nodes: nodes.map { $0 ** s })
}


/// 't⊥' replaces all variables in t with constant '⊥'.
postfix func ⊥<T:Node where T.Symbol == String>(t:T) -> T {
    return t ** T(constant:"⊥")
}

/// 't⊥' replaces all variables in t with constant '⊥'.
postfix func ⊥<T:Node where T.Symbol == Tptp.Symbol>(t:T) -> T {
    return t ** T(constant:Tptp.Symbol("⊥",.Function))
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
        assert(self.isHomogenous)
        return allKeysAreVariables
    }

    /// A variable substitution maps variables to variables.
    var isVariableSubstitution : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables && allValuesAreVariables
    }

    /// A (variable) renaming maps distinct variables to distinguishable variables.
    var isRenaming : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables && allValuesAreVariables && isInjective
    }
}
