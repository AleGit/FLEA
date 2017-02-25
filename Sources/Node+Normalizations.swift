//  Copyright © 2017 Alexander Maringele. All rights reserved.

/* This file contains extensions for protocol `Node` to alter variable names,
 when symbols are `SymbolNameTyped`:
 - append same (separator and) suffix to all variable names
 - remove separator and suffix from variable names
 - normalize variable names with common symbol, (separator), and increasing suffix
 - normalize variable names with same symbol and extract variable symbols by preorder traversing
 - denormalize variable names by renaming variable names with list of symbols by preorder traversing
 */

extension Node where Self: SymbolNameTyped {
    // implies Symbol: Hashable

    /// Constructs a new tree where a suffix is appended to all variable names
    func appending<T: Any>(separator: String = "_", suffix: T) -> Self {
        guard let nodes = self.nodes else {
            let (string, type) = self.symbolNameType
            Syslog.error(condition: type != .variable) {
                "Node(symbol:\(self.symbol), nodes:nil) must not be of type \(type)."
            }
            let symbol = Self.symbolize(name: "\(string)\(separator)\(suffix)", type: type)
            return Self(symbol: symbol, nodes: nil)
        }

        return Self(symbol: self.symbol, nodes: nodes.map { $0.appending(suffix: suffix) })
    }

    // Constructs a new tree where suffixes are removed from variable names
    private func desuffixing(separator: String,
                             mappings: inout Dictionary<String, String>) -> Self {
        guard let nodes = self.nodes else {
            let (string, type) = self.symbolNameType
            Syslog.error(condition: type != .variable) {
                "Node with nil nodes must be of type variable."
            }

            // check if variable string was already desuffixed to name
            if let name = mappings[string] {
                return Self(symbol: Self.symbolize(name: name, type: .variable), nodes: nil)
            }

            // split string, e.g. "x_3" -> ["x","3"] if separator was "_"
            let components = string.components(separatedBy: separator)

            Syslog.error(condition: components.count > 2) {
                "Can not handle \(string) with \(components.count) components."
            }

            guard let name = components.first else {
                Syslog.error { "Can not handle \(string) with no components." }
                return self
            }

            guard !mappings.values.contains(name) else {
                Syslog.warning { "\(mappings) did not contain string key '\(string)', but contains name value '\(name)'." } // -> warning
                Syslog.error(condition: mappings.values.contains(string)) { "\(mappings) contains string key '\(string)' as name value."}
                mappings[string] = string
                return self
            }

            mappings[string] = name

            return Self(symbol: Self.symbolize(name: name, type: .variable), nodes: nil)
        }

        return Self(symbol: self.symbol, nodes: nodes.map {
            $0.desuffixing(separator: separator, mappings: &mappings) }
        )
    }

    @available(*, deprecated, message: "- for experimental purposes only -")
    /// remove unnecessary suffixes
    func desuffixing(separator: String = "_") -> Self {
        Syslog.error(condition: separator.isEmpty) { "Must not use empty suffix separator" }
        var m = Dictionary<String, String>()
        return desuffixing(separator: separator, mappings: &m)
    }

    /* prefix normalization */

    /// Constructs a new tree where variable names are prefix normalized
    /// - f(X,Y,g(Y)).normalized(prefix:Z) -> f(Z0,Z1,g(Z1)
    /// - f(X,Y,g(Y)).normalized(prefix:Z, separator:_) -> f(Z_0,Z_1,g(Z_1))
    /// - f(X,Y,g(Y)).normalized(prefix:Z, offset:1) -> f(Z1,Z2,g(Z2))
    /// - f(X,Y,g(Y)).normalized(prefix:*, offset:1) -> f(1,2,g(2))
    func normalized<T: Any>(prefix: T, separator: String = "", offset: Int = 0) -> Self {
        var renamings = Dictionary<Symbol, Symbol>()

        return self.normalized(prefix: prefix, separator: separator, offset: offset,
                               renamings: &renamings)
    }

    private func normalized<T: Any>(prefix: T, separator: String, offset: Int,
                                    renamings: inout Dictionary<Symbol, Symbol>) -> Self {
        if let nodes = self.nodes {
            // not a variable
            return Self(symbol: self.symbol, nodes: nodes.map {
                $0.normalized(prefix: prefix, separator: separator, offset: offset, renamings: &renamings)
            })
        }

        if let symbol = renamings[self.symbol] {
            // variable symbol was allready encountered
            return Self(variable: symbol)
        }

        // variable symbol is unknown so far
        let symbol = Self.symbolize(
            name: "\(prefix)\(separator)\(renamings.count + offset)",
            type: .variable)
        renamings[self.symbol] = symbol
        return Self(variable: symbol)
    }

    /* placeholder normalization */

    /// Constructs a new tree where all variables are renamed to `hole`
    /// and the list of variable symbols in preorder traversal
    /// - f(X,Y,g(Y)).normalized() -> (f(□,□,g(□)), [X,Y,Y])
    func normalized(hole: String = "□") -> (Self, Array<Self.Symbol>) {
        var symbols = Array<Self.Symbol>()
        let result = self.normalized(hole: hole, symbols: &symbols)
        return (result, symbols)
    }

    /// To be called by func normalized(hole: String = "□") only.
    private func normalized(hole: String = "□", symbols: inout Array<Self.Symbol>) -> Self {
        guard let nodes = self.nodes else {
            symbols.append(self.symbol)
            return Self(v: hole)
        }

        guard nodes.count > 0 else {
            return Self(constant: self.symbol)
        }

        var children = [Self]()
        for node in nodes {
            children.append(node.normalized(hole: hole, symbols: &symbols))
        }

        return Self(symbol: self.symbol, nodes: children)
    }

    /// Constructs a tree where all variables are renamed with elements of a list of symbols
    /// If the tree has more variable positions than symbols in the list then nil is returned.
    /// The sequence of variables is determined by preorder traversal.
    /// - (f(□,□,g(□)).denormalizing(with:[A,B,C]) -> f(A,B,g(C))
    /// - (f(X,Y,g(X)).denormalizing(with:[A,B,C]) -> f(A,B,g(C))
    /// - (f(X,Y,g(X)).denormalizing(with:[A,B]) -> nil
    /// - (f(X,Y,g(X)).denormalizing(with:[A,B,C,E]) -> f(A,B,g(C))
    func denormalizing(with symbols: Array<Self.Symbol>) -> Self? {
        var copy = symbols
        let result = self.denormalized(symbols: &copy)

        Syslog.warning(condition: copy.count > 0) {
            "\(self) has more variable positions than\n\(symbols) has members"
        }

        return result
    }

    private func denormalized(symbols: inout Array<Self.Symbol>) -> Self? {

        guard let nodes = self.nodes else {
            guard symbols.count > 0 else { return nil } // too few symbols
            return Self(variable: symbols.removeFirst())
        }

        var children = [Self]()
        for node in nodes {
            guard let child = node.denormalized(symbols: &symbols) else {
                return nil
            }
            children.append(child)
        }
        return Self(symbol: self.symbol, nodes: children)
    }
}
