/// String MUST NOT be TypedName because it cannot store the SymbolType reliable.

extension String {
    static var NIL = "<nil>"
    static var stringTypes = [
        "!": Tptp.SymbolType.universal,
        "∀": Tptp.SymbolType.universal,
        "?": Tptp.SymbolType.existential,
        "∃": Tptp.SymbolType.existential,
        "~": Tptp.SymbolType.negation,
        "￢": Tptp.SymbolType.negation,
        "|": Tptp.SymbolType.disjunction,
        "∨": Tptp.SymbolType.disjunction,
        "&": Tptp.SymbolType.conjunction,
        "∧": Tptp.SymbolType.conjunction,
        "=>": Tptp.SymbolType.implication,
        "→": Tptp.SymbolType.implication,
        "<=": Tptp.SymbolType.reverseimpl,
        "←": Tptp.SymbolType.reverseimpl,
        "=": Tptp.SymbolType.equation,
        "!=": Tptp.SymbolType.inequation,
        "<~>": Tptp.SymbolType.xor,
        "⊻": Tptp.SymbolType.xor,
        "⊕": Tptp.SymbolType.xor,
        "~|": Tptp.SymbolType.nor,
        "⊽": Tptp.SymbolType.nor,
        "~&": Tptp.SymbolType.nand,
        "⊼": Tptp.SymbolType.nand,
        "<=>": Tptp.SymbolType.bicondition,
        "↔": Tptp.SymbolType.bicondition,
    ]

    var symbolType: Tptp.SymbolType {
        if let type = String.stringTypes[self] {
            return type
        }
        if isUppercased(at: startIndex) {
            return .variable
        }
        return .undefined
    }

    /// String literals to be converted to nodes can be annotated
    /// with the type of its root node to avoid ambiguity.
    var tptpStringLiteralType: (String, Tptp.SymbolType) {
        if isEmpty {
            return (self, .undefined)
        }

        // ANNOTATED

        if hasPrefix("@") {
            for (prefix, type) in [
                "@cnf ": Tptp.SymbolType.cnf,
                "@fof ": Tptp.SymbolType.fof,

                "@include ": Tptp.SymbolType.include,
                "@file ": Tptp.SymbolType.file,

            ] {
                if hasPrefix(prefix) {
                    let s = substring(from: range(of: prefix)!.upperBound)
                    return (s, type)
                }
            }
            Syslog.warning { "Undefined annotation in \(self)" }
        }

        // HEURISTICS

        // not annotated strings with connectives are fof.

        if containsOne([
            "?", "!", "~", "-->",
            "&", "|", "=>", "<=>", "=",
            "~&", "~|", "<=", "<~>", "~=",
        ]) {
            return (self, .fof)
        }

        // not annotated strings without connectives are terms.

        return (self, .function(-1)) // .function(_) or .variable
    }
}
