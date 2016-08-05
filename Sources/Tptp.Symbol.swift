import CTptpParsing

// MARK: - Tptp.Symbol

extension Tptp {
  struct Symbol : Symbolable {
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
    case reverseimpl  // s <= t
    case bicondition // s <=> t
    case xor  // <~>
    case nand // ~&
    case nor // ~|

    // case gentzen // -->
    // case star // *
    // case plus // +

    // $true
    // $false

    case equation   // s = t
    case inequation // s != t

    case predicate  // predicates and propositions
    case function   // functions and constants
    case variable   // variables
  }
}

extension Tptp.SymbolType {

  init(of node:TreeNodeRef) {

    guard let symbol = node.symbol else {
      self =  .undefined
      return
    }
    let type = node.type

    switch (symbol, type) {

      /* logical symbols */

      case ("!", _):
        assert (type == PRLC_QUANTIFIER, "'\(symbol)' is not a quantifier \(type).")
        self = .universal
      case ("?", _):
        assert (type == PRLC_QUANTIFIER, "'\(symbol)' is not a quantifier \(type).")
        self = .existential

      case ("~", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .negation
      case ("|", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .disjunction
      case ("&", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .conjunction
      case ("=>", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .implication
      case ("<=", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .reverseimpl
      case ("<=>", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .bicondition

      case ("<~>", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .xor
      case ("~&", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .nand
      case ("~|", _):
        assert (type == PRLC_CONNECTIVE, "'\(symbol)' is not a connective \(type).")
        self = .nor

      /* error */
      case (_, PRLC_CONNECTIVE):
        assert(false,"Unknown connective '\(symbol)'")
        self = .undefined

      case ("=", _):
        assert (type == PRLC_EQUATIONAL, "'\(symbol)' is not equational \(type).")
        self = .equation
      case ("!=", _):
        assert (type == PRLC_EQUATIONAL, "'\(symbol)' is not equational \(type).")
        self = .inequation

      /* error */
      case (_, PRLC_EQUATIONAL):
        assert(false, "Unknown equational '\(symbol)'")
        self = .undefined

      case (_, PRLC_PREDICATE):
        self = .predicate

      case (_, PRLC_FUNCTION):
        self = .function

      case (_, PRLC_VARIABLE):
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
}

extension Tptp.Symbol : Hashable {
  /// Hashable
  var hashValue : Int {
    return self.string.hashValue
  }
}

/// Tptp.Symbol : Hashable : Equatable
func ==(lhs:Tptp.Symbol, rhs:Tptp.Symbol) -> Bool {
  return lhs.string == rhs.string && lhs.type == rhs.type
}

extension Tptp.Symbol : CustomStringConvertible {
  /// CustomStringConvertible
  var description:String {
    return self.string
  }
}

extension Tptp.Symbol : CustomDebugStringConvertible {
  var debugDescription:String {
    return "\(self.string)-\(self.type)"
  }
}

protocol SymbolTable {
  associatedtype Symbol : Symbolable

  mutating func insert(_ string: String, _ type:Tptp.SymbolType) -> Symbol
  subscript(symbol:Symbol) -> String? { get }
}
