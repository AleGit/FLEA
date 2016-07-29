import CTptpParsing

// MARK: - protocol -

protocol Symbolable : Hashable {

  /// the empty symbol
  // static var empty: Self { get }

  var string : String { get }
  var type : Tptp.SymbolType { get }

  init(_ string: String, _ type: Tptp.SymbolType)
}

extension Symbolable {
  /// Initialze a symbol with symbol:String (and type)
  /// of a node in the abstract syntax tree.
  init(of node:TreeNodeRef) {
    let string = node.symbol ?? "n/a"
    let type = Tptp.SymbolType(of:node)

    self = Self(string, type)
  }
}

extension Symbolable {
  static var empty : Self {
    return Self("",.undefined)
  }
}

// MARK: - Tptp.Symbol

extension Tptp {
  struct Symbol : Hashable, CustomDebugStringConvertible {
    let string : String
    let type : SymbolType

    init(_ string: String, _ type: SymbolType ) {
      self.string = string
      self.type = type
    }
  }
}

extension Tptp {
  enum SymbolType : Int {
    case undefined = 0

    /// <TPTP_file>
    case file

    /// <fof_annotated>
    case fof
    /// <cnf_annotated>
    case cnf
    /// <include>
    case include    // file name

    case name

    case role
    case annotation

    case universal    // ! X Y s
    case existential  // ? X Y s

    case negation     // ~ s
    case disjunction  // s | t ...
    case conjunction  // s & t ...
    case implication  // s => t

    case equation   // s = t
    case inequation // s != t

    case predicate  // predicates and propositions
    case function   // functions and constants
    case variable   // variables
  }
}

extension Tptp.SymbolType {
  init(of node:TreeNodeRef) {
    let symbol = node.symbol ?? "n/a"
    let type = node.type

    switch (symbol, type) {
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

      case ("!", _):
        assert (type == PRLC_QUANTIFIER)
        self = .universal
      case ("?", _):
        assert (type == PRLC_QUANTIFIER)
        self = .existential

      case ("|", _):
        assert (type == PRLC_CONNECTIVE)
        self = .disjunction
      case ("&", _):
        assert (type == PRLC_CONNECTIVE)
        self = .conjunction
      case ("=>", _):
        assert (type == PRLC_CONNECTIVE)
        self = .implication
      case ("~", _):
        assert (type == PRLC_CONNECTIVE)
        self = .negation

      case ("=", _):
        assert (type == PRLC_EQUATIONAL)
        self = .equation
      case ("!=", _):
        assert (type == PRLC_EQUATIONAL)
        self = .inequation

      case (_, PRLC_PREDICATE):
        self = .predicate

      case (_, PRLC_FUNCTION):
        self = .function
      case (_, PRLC_VARIABLE):
        self = .variable

      default:
        self = .undefined
      }
  }
}

// extension Tptp.Symbol : Symbolable {
//   static var empty : Tptp.Symbol {
//     return Tptp.Symbol("",.undefined)
//   }
// }

extension Tptp.Symbol : Symbolable {
  /// Hashable
  var hashValue : Int {
    return self.string.hashValue
  }
}

extension Tptp.Symbol {
  /// CustomStringConvertible
  var description:String {
    return self.string
  }

  /// CustomDebugStringConvertible
  var debugDescription:String {
    return "\(self.string)-\(self.type)"
  }
}

/// Tptp.Symbol : Hashable : Equatable
func ==(lhs:Tptp.Symbol, rhs:Tptp.Symbol) -> Bool {
  return lhs.string == rhs.string && lhs.type == rhs.type
}
