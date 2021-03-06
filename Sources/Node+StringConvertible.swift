// MARK: - Node:CustomStringConvertible

extension Node {
    /// implementations of Node will call this
    var description: String { return defaultDescription }

    /// possible usage: lazy var description = defaultDescritpion
    var defaultDescription: String {
        let s = "\(symbol)"
        // without reliable symbol type information, everything is a prefix function.
        // empty parenthesis will be ommitted, e.g. for variables, constants, predicates.
        return buildDescription(string: s, type: .function(nodes?.count ?? -1))
    }
}

extension Node where Self: SymbolNameTyped {
    var defaultDescription: String {
        let (string, type) = symbolNameType
        return buildDescription(string: string, type: type)
    }
}

extension Node {

    /// Build a description with symbol string and type.
    func buildDescription(string: String, type: Tptp.SymbolType) -> String {
        guard let nodes = self.nodes?.map({ $0.description }), nodes.count > 0 else {
            return string
        }
        switch type {
        case .universal, .existential:
            assert(nodes.count > 0)
            let vars = nodes[0 ..< (nodes.count - 1)].joined(separator: ",")
            return "\(string)[\(vars)]\(nodes.last!)"

        case .negation:
            assert(nodes.count == 1)
            return "\(string)(\(nodes.first!))"

        case .disjunction, .conjunction:
            assert(nodes.count > 0)
            let tuple = nodes.joined(separator: string)
            return "(\(tuple))"

        case .implication, .reverseimpl,
             .bicondition, .xor, .nand, .nor:
            assert(nodes.count == 2)
            return "(\(nodes.first!)\(string)\(nodes.last!))"

        case .equation, .inequation:
            assert(nodes.count == 2)
            return nodes.joined(separator: string)

        default: // prefix notation
            assert(nodes.count > 0)
            let tuple = nodes.joined(separator: ",")
            return "\(string)(\(tuple))"
        }
    }
}

// MARK: - Node.CustomDebugStringConvertible

extension Node {
    /// Build a more verbose description in prefix notation.
    func buildDebugDescription(string: String) -> String {
        guard let nodes = self.nodes?.map({ $0.debugDescription }), nodes.count > 0
        else { return string }
        let tuple = nodes.joined(separator: ",")
        return "\(string)(\(tuple))"
    }
}

extension Node {
    var debugDescription: String {
        // without reliable string and type information we just use string interpolation
        return buildDebugDescription(string: "\(symbol)")
    }
}

extension Node where Symbol == String {
    var debugDescription: String {
        assert(false, "Do not use symole String as Node.Symbol")
        return buildDebugDescription(string: symbol)
    }
}

extension Node where Symbol == Tptp.Symbol {
    var debugDescription: String {
        return buildDebugDescription(string: "\(symbol.debugDescription)")
    }
}

/* compile error !?, but shoul unify code below
 extension Node where Self:SymbolNameTyped {
 var debugDescription: String {
 return buildDebugDescription(string:"\(self.symbol)")
 // return buildDebugDescription(string:"\(self.symbol)-\(self.symbolNameType)")
 }
 }
 */

extension Node where Symbol: TypedName {
    var debugDescription: String {
        // with reliable string and type information we use it
        return buildDebugDescription(string: "\(symbol)-\(symbol.name)-\(symbol.type)")
    }
}

extension Node where Self: SymbolTabulating, Symbol == Self.Symbols.Symbol,
    Self.Symbols.Key == String {
    var debugDescription: String {
        let (string, type) = Self.symbols[self.symbol] ?? ("\(symbol)", .undefined)

        return buildDebugDescription(string: "\(symbol)-\(string)-\(type)")
    }
}
