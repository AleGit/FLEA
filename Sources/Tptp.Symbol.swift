import CTptpParsing

// MARK: - Tptp.Symbol

extension Tptp {
    struct Symbol: StringSymbolable {
        let string: String
        let type: SymbolType

        init(_ string: String, _ type: SymbolType) {
            self.string = string
            self.type = type
        }
    }
}

// swiftlint:disable variable_name
extension Node where Self: SymbolStringTyped {
    init(v: String) {
        let s = Self.symbolize(string: v, type: .variable)
        self.init(variable: s)
    }

    init(c: String) {
        let s = Self.symbolize(string: c, type: .function(0))
        self.init(constant: s)
    }

    init(f: String, _ nodes: [Self]) {
        let s = Self.symbolize(string: f, type: .function(nodes.count))
        self.init(symbol: s, nodes: nodes)
    }

    init(p: String, _ nodes: [Self]) {
        let s = Self.symbolize(string: p, type: .predicate(nodes.count))
        self.init(symbol: s, nodes: nodes)
    }
}

// swiftlint:enable variable_name

extension Tptp {
    enum Role: String {
        case axiom, hypothesis, definition, assumption
        case lemma, theorem, corollary, conjecture
        case negated_conjecture
        case plain, type
        case fi_domain, fi_functors, fi_predicates
        case unknown
    }

    enum SymbolType: Equatable {
        case undefined

        /// <TPTP_file>
        case file

        /// <fof_annotated>
        case fof
        /// <cnf_annotated>
        case cnf
        /// <include>
        case include // file name

        case name

        case role
        case annotation

        case universal // ! X Y ... s with implicit arity == 1..<∞
        case existential // ? X Y ... s with implicit arity == 1..<∞

        case negation // ~ s with implicit arity == 1
        case disjunction // s, t ... with implicit arity == 0..<∞
        case conjunction // s & t ... with implicit arity == 0..<∞

        case implication // s => t with implicit arity == 2
        case reverseimpl // s <= t with implicit arity == 2
        case bicondition // s <=> t with implicit arity == 2
        case xor // <~> with implicit arity == 2
        case nand // ~& with implicit arity == 2
        case nor // ~| with implicit arity == 2

        // case gentzen // -->
        // case star // *
        // case plus // +

        // $true
        // $false

        case equation // s = t with implicit arity == 2
        case inequation // s != t with implicit arity == 2

        case predicate(Int) // predicates and propositions with symolb fixed arity

        case function(Int) // functions and constants with symbol fixed arity
        case variable // variables
    }
}

func == (lhs: Tptp.SymbolType, rhs: Tptp.SymbolType) -> Bool {
    switch (lhs, rhs) {
    case (.file, .file),
         (.fof, .fof),
         (.cnf, .cnf),
         (.include, .include),
         (.name, .name),
         (.role, .role),
         (.annotation, .annotation),
         (.universal, .universal),
         (.existential, .existential),
         (.negation, .negation),
         (.disjunction, .disjunction),
         (.conjunction, .conjunction),
         (.implication, .implication),
         (.reverseimpl, .reverseimpl),
         (.bicondition, .bicondition),
         (.xor, .xor),
         (.nand, .nand),
         (.nor, .nor),
         (.equation, .equation),
         (.inequation, .inequation),
         (.variable, .variable),

         (.undefined, .undefined):
        return true
    case (.predicate(let larity), .predicate(let rarity)):
        return larity == rarity
    case (.function(let larity), .function(let rarity)):
        return larity == rarity
    default:
        return false
    }
}

extension Tptp.SymbolType {

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    init(of node: TreeNodeRef) {

        guard let string = node.symbol else {
            self = .undefined
            return
        }
        let type = node.type

        switch (string, type) {

            /* logical symbols */

        case ("!", _):
            assert(type == PRLC_QUANTIFIER, "'\(string)' is not a quantifier \(type).")
            self = .universal
            // assert (string.symbolType == Tptp.SymbolType.universal)

        case ("?", _):
            assert(type == PRLC_QUANTIFIER, "'\(string)' is not a quantifier \(type).")
            self = .existential
            // assert (string.symbolType == Tptp.SymbolType.existential)

        case ("~", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .negation
            // assert (string.symbolType == Tptp.SymbolType.negation)

        case ("|", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .disjunction
            // assert (string.symbolType == Tptp.SymbolType.disjunction)

        case ("&", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .conjunction
            // assert (string.symbolType == Tptp.SymbolType.conjunction)

        case ("=>", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .implication
            // assert (string.symbolType == Tptp.SymbolType.implication)

        case ("<=", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .reverseimpl
            // assert (string.symbolType == Tptp.SymbolType.reverseimpl)

        case ("<=>", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .bicondition
            // assert (string.symbolType == Tptp.SymbolType.bicondition)

        case ("<~>", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .xor
            // assert (string.symbolType == Tptp.SymbolType.xor)

        case ("~&", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .nand
            // assert (string.symbolType == Tptp.SymbolType.nand)

        case ("~|", _):
            assert(type == PRLC_CONNECTIVE, "'\(string)' is not a connective \(type).")
            self = .nor
            // assert (string.symbolType == Tptp.SymbolType.nor)

            /* error */
        case (_, PRLC_CONNECTIVE):
            assert(false, "Unknown connective '\(string)'")
            self = .undefined

        case ("=", _):
            assert(type == PRLC_EQUATIONAL, "'\(string)' is not equational \(type).")
            self = .equation
            // assert (string.symbolType == Tptp.SymbolType.equation)

        case ("!=", _):
            assert(type == PRLC_EQUATIONAL, "'\(string)' is not equational \(type).")
            self = .inequation
            // assert (string.symbolType == Tptp.SymbolType.inequation)

            /* error */
        case (_, PRLC_EQUATIONAL):
            assert(false, "Unknown equational '\(string)'")
            self = .undefined

        case (_, PRLC_PREDICATE):
            self = .predicate(node.childCount)
            // assert (string.symbolType == Tptp.SymbolType.undefined)

        case (_, PRLC_FUNCTION):
            self = .function(node.childCount)
            // assert (string.symbolType == Tptp.SymbolType.undefined)

        case (_, PRLC_VARIABLE):
            // assert (string.symbolType == Tptp.SymbolType.variable)
            self = .variable

            /* non-logical symbols */

        case (_, PRLC_FILE):
            self = .file
        case (_, PRLC_FOF):
            self = .fof
        case (_, PRLC_CNF):
            self = .cnf
        case (_, PRLC_INCLUDE):
            self = .include
        case (_, PRLC_ROLE):
            self = .role
        case (_, PRLC_ANNOTATION):
            self = .annotation

        default:
            self = .undefined
        }
    }

    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}

extension Tptp.Symbol: Hashable {
    /// Hashable
    var hashValue: Int {
        return self.string.hashValue
    }
}

/// Tptp.Symbol : Hashable : Equatable
func == (lhs: Tptp.Symbol, rhs: Tptp.Symbol) -> Bool {
    return lhs.string == rhs.string && lhs.type == rhs.type
}

extension Tptp.Symbol: CustomStringConvertible {
    /// CustomStringConvertible
    var description: String {
        return self.string
    }
}

extension Tptp.Symbol: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(self.string)-\(self.type)"
    }
}
