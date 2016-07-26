import CTptpParsing

protocol Symbolable : Hashable {
  static var empty: Self { get }
  var symbol : String { get }
  var type : Tptp.SymbolType { get }
}

extension String : Symbolable {
  static var empty : String { return "" }
  var symbol : String { return self }
  var type: Tptp.SymbolType {
    switch self {
      case "|":
        return .disjunction
      default:
        return .Undefined
    }
  }
}



extension Tptp {
  enum SymbolType {
    case Undefined

    /// <TPTP_file>
    case File

    /// <fof_annotated>
    case Fof
    /// <cnf_annotated>
    case Cnf
    /// <include>
    case Include    // file name

    case Name

    case Role
    case Annotation

    case Universal    // ! X Y s
    case Existential  // ? X Y s

    case negation     // ~ s
    case disjunction  // s | t ...
    case Conjunction  // s & t ...
    case Implication  // s => t

    case equation   // s = t
    case inequation // s != t

    case predicate  // predicates and propositions
    case Function   // functions and constants
    case Variable   // variables
  }

  struct Symbol : Hashable, CustomDebugStringConvertible {
    let symbol : String
    let type : SymbolType

    init(_ symbol: String, _ type: SymbolType ) {
      self.symbol = symbol
      self.type = type
    }
  }
}

extension Tptp.Symbol : Symbolable {
  static var empty : Tptp.Symbol {
    return Tptp.Symbol("",.Undefined)
  }
}

extension Tptp.Symbol {
  /// Hashable
  var hashValue : Int {
    return self.symbol.hashValue
  }
}

extension Tptp.Symbol {
  /// CustomStringConvertible
  var description:String {
    return self.symbol
  }

  /// CustomDebugStringConvertible
  var debugDescription:String {
    return "\(self.symbol)-\(self.type)"
  }
}

/// Tptp.Symbol : Hashable : Equatable
func ==(lhs:Tptp.Symbol, rhs:Tptp.Symbol) -> Bool {
  return lhs.symbol == rhs.symbol && lhs.type == rhs.type
}

extension Tptp.Symbol {
  init(symbol:String, type:PRLC_TREE_NODE_TYPE) {
    switch (symbol,type) {

      case (_, PRLC_FILE):
        self = Tptp.Symbol(symbol,.File)

      case (_, PRLC_FOF):
        self = Tptp.Symbol(symbol,.Fof)
      case (_, PRLC_CNF):
        self = Tptp.Symbol(symbol,.Cnf)
      case (_, PRLC_INCLUDE):
        self = Tptp.Symbol(symbol,.Include)

      case (_, PRLC_ROLE):
        self = Tptp.Symbol(symbol,.Role)
      case (_, PRLC_ANNOTATION):
        self = Tptp.Symbol(symbol,.Annotation)

      case ("!", _):
        assert (type == PRLC_QUANTIFIER)
        self = Tptp.Symbol(symbol,.Universal)
      case ("?", _):
        assert (type == PRLC_QUANTIFIER)
        self = Tptp.Symbol(symbol,.Existential)

      case ("|", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.disjunction)
      case ("&", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.Conjunction)
      case ("=>", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.Implication)
      case ("~", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.negation)

      case ("=", _):
        assert (type == PRLC_EQUATIONAL)
        self = Tptp.Symbol(symbol,.equation)
      case ("!=", _):
        assert (type == PRLC_EQUATIONAL)
        self = Tptp.Symbol(symbol,.inequation)

      case (_, PRLC_PREDICATE):
        self = Tptp.Symbol(symbol,.predicate)

      case (_, PRLC_FUNCTION):
        self = Tptp.Symbol(symbol,.Function)
      case (_, PRLC_VARIABLE):
        self = Tptp.Symbol(symbol,.Variable)

      default:
        self = Tptp.Symbol(symbol,.Undefined)
    }
  }
}
