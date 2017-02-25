extension Node where Self: SymbolNameTyped {
    static var joker: Symbol {
        return Self.symbolize(name: Tptp.wildcard, type: .variable)
    }

    /// Prefix paths from root to leaves.
    /// p(x,g(a,y)) -> { p.1.*, p.2.g.1.a, p.2.g.2.* }
    /// ~q(f(x,y),b) -> { ~.0.q.1.f.1.*, ~.0.q.1.f.2.*, ~.0.q.2.b}
    /// a=f(x,b) -> { =.0.a, =.1.f.0.*, =.1.f.1.b}
    var leafPaths: [[SymHop<Symbol>]] {
        guard let nodes = self.nodes else {
            return [[.symbol(Self.joker)]]
        }
        guard nodes.count > 0 else {
            return [[.symbol(self.symbol)]]
        }

        let sym = SymHop.symbol(self.symbol)

        var ps = [[SymHop<Symbol>]]()
        for (i, node) in nodes.enumerated() {
            let hop: SymHop<Symbol> = SymHop.hop(i)
            for path in node.leafPaths {
                ps.append([sym, hop] + path)
            }
        }
        return ps
    }

    /// Prefix paths from root to leaves and negated root to leaves.
    /// p(x,g(a,y)) -> { p.1.*, p.2.g.1.a, p.2.g.2.* }, { ~.0.p.1.*, ~.0.p.2.g.1.a, ~.0.p.2.g.2.* }
    /// ~q(f(x,y),b) -> { ~.0.q.1.f.1.*, ~.0.q.1.f.2.*, ~.0.q.2.b}, { q.1.f.1.*, q.1.f.2.*, q.2.b}
    /// a=f(x,b) -> { =.0.a, =.1.f.0.*, =.1.f.1.b}, { !=.0.a, !=.1.f.0.*, !=.1.f.1.b}
    var leafPathsPair: ([[SymHop<Symbol>]], [[SymHop<Symbol>]]) {
        let paths = leafPaths

        let negated: [[SymHop<Symbol>]]
        let (_, type) = self.symbolNameType

        switch type {

        case .negation:
            assert(self.nodes?.count == 1)
            negated = paths.map { Array($0.suffix(from: 2)) }

        case .equation:
            let symbol = Self.symbolize(name: "!=", type: .inequation)
            negated = paths.map { [.symbol(symbol)] + $0.suffix(from: 1) }

        case .inequation:
            let symbol = Self.symbolize(name: "=", type: .equation)
            negated = leafPaths.map { [.symbol(symbol)] + $0.suffix(from: 1) }

        case .predicate:
            let symbol = Self.symbolize(name: "~", type: .negation)
            negated = paths.map { [.symbol(symbol), .hop(0)] + $0 }

        default:
            Syslog.error { "\(self) with root type \(type) cannot be negated." }
            negated = [[SymHop<Symbol>]]()
        }

        Syslog.debug { "\(self), \(paths), \(negated)" }

        return (paths, negated)
    }
}

extension Node where Symbol == Int, Self: SymbolNameTyped {
    var joker: Symbol {
        return -1
    }

    /// Prefix paths from root to leaves.
    /// f(x,g(a,y)) -> { f.1.*, f.2.g.1.a, f.2.g.2.* }
    /// g(f(x,y),b) -> { g.1.f.1.*, g.1.f.2.*, g.2.b}
    var leafPaths: [[Int]] {
        guard let nodes = self.nodes else {
            return [[Self.joker]]
        }
        guard nodes.count > 0 else {
            return [[self.symbol]]
        }

        var ps = [[Int]]()
        for (hop, node) in nodes.enumerated() {
            for path in node.leafPaths {
                ps.append([self.symbol, hop] + path)
            }
        }
        return ps
    }

    var leafPathsPair: ([[Int]], [[Int]]) {
        let paths = leafPaths

        let negated: [[Int]]
        let (_, type) = self.symbolNameType

        switch type {

        case .negation:
            assert(self.nodes?.count == 1)
            negated = paths.map { Array($0.suffix(from: 2)) }

        case .equation:
            let symbol = Self.symbolize(name: "!=", type: .inequation)
            negated = paths.map { [symbol] + $0.suffix(from: 1) }

        case .inequation:
            let symbol = Self.symbolize(name: "=", type: .equation)
            negated = leafPaths.map { [symbol] + $0.suffix(from: 1) }

        case .predicate:
            let symbol = Self.symbolize(name: "~", type: .negation)
            negated = paths.map { [symbol, 0] + $0 }

        default:
            Syslog.error { "\(self) with root type \(type) cannot be negated." }
            assert(false)
            negated = [[Int]]()
        }

        Syslog.debug { "\(self), \(paths), \(negated)" }

        return (paths, negated)
    }
}

extension Node where Self: SymbolNameTyped {
    /// The list of symbols in the node tree in depth-first tree traversal.
    var preorderTraversalSymbols: [Symbol] {
        guard let nodes = self.nodes else {
            // a variable leaf
            // assert(false, "shoot the messanger!")
            return [Self.symbolize(name: Tptp.wildcard, type: .variable)]
        }
        guard nodes.count > 0 else {
            // a constant (function) leaf
            return [self.symbol]
        }

        // an intermediate node
        return nodes.reduce([self.symbol]) { $0 + $1.preorderTraversalSymbols }
    }
}

extension Node where Self: SymbolNameTyped, Self.Symbol == Int {
    var preorderTraversalSymbols: [Symbol] {
        guard let nodes = self.nodes else {
            // a variable leaf
            return [-1]
        }
        guard nodes.count > 0 else {
            // a constant (function) leaf
            return [self.symbol]
        }

        // an intermediate node
        return nodes.reduce([self.symbol]) { $0 + $1.preorderTraversalSymbols }
    }

}
