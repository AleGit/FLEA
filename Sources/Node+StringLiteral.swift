// ExpressibleByStringLiteral : ExtendedGraphemeClusterLiteralConvertible  : UnicodeScalarLiteralConvertible

extension Node where Self: SymbolNameTyped {

    /// _UnicodeScalarLiteralConvertible_
    init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }

    /// _ExtendedGraphemeClusterLiteralConvertible_
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }

    /// _ExpressibleByStringLiteral_
    /// The flexible conversion of strings lets us easily create
    /// variable, constants, terms, liteals, clauses and formulas,
    /// but this not always unambiguous:
    /// - Is 'p' in 'p(f(X))' a function or a predicate symbol?
    /// - Is 'p(f(X))' a literal or unary clause?
    ///
    /// *Annotations and Heuristics*
    ///
    /// String literals can be annotated:
    /// - "@fof p(f(X))" -> first order formula, a predicate literal.
    /// - "@cnf p(f(X))" -> clause with one predicate literal.
    /// - "p(f(X))" -> term, p is a function symbol

    /// Annotations may introduce syntax errors for well formed formulas:
    /// - "@cnf a&b" -> undefined
    /// - "a&b" -> first order formula, a conjunction of two propositions.
    ///
    /// In many cases there is no need for annotations:
    ///
    /// - first order formula if string contains logical symbols
    /// - _term_ otherwise
    init(stringLiteral value: StringLiteralType) {
        // let fof = "fof(name,role,predicate(\(value))."
        self.init()

        let (string, type) = value.tptpStringLiteralType

        guard !string.isEmpty else {
            self = Self(c: "ε")
            return
        }

        guard let file = Tptp.File(string: string, type: type) else {
            self = Self(c: "\(value) ❌ .parse error")
            return
        }

        let a: Self? = file.ast()

        guard var ast = a else {
            self = Self(c: "\(value).❌ .❌ .no ast")
            return
        }

        defer {
            self = ast
        }

        if type == .file || type == .include {
            return // deferred self = ast will be executed
        }

        guard let nodes = ast.nodes?.first?.nodes, nodes.count > 0 else {
            return // deferred self = ast will be executed
        }

        ast = nodes[1] // fof_formula or cnf_formula

        if let term = ast.nodes?.first, type == .variable || type == .function(-1) {
            ast = term
        }
    }
}
