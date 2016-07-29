import CTptpParsing

// MARK: - protocol -

protocol Symbolable : Hashable {

  /// the empty symbol
  static var empty: Self { get }

  var string : String { get }
  var type : Tptp.SymbolType { get }

  /// Initialze a symbol with symbol (and type)
  /// of a node in the abstract syntax tree.
  init(of node:TreeNodeRef)
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

extension Tptp.Symbol : Symbolable {
  static var empty : Tptp.Symbol {
    return Tptp.Symbol("",.undefined)
  }
}

extension Tptp.Symbol {
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

extension Tptp.Symbol {
  // init(symbol:String, type:PRLC_TREE_NODE_TYPE) {
  init(of node:TreeNodeRef) {
    let symbol = node.symbol ?? "n/a" // hide self.symbol
    let type = node.type              // hide self.type

    switch (symbol, type) {

      case (_, PRLC_FILE):
        self = Tptp.Symbol(symbol,.file)

      case (_, PRLC_FOF):
        self = Tptp.Symbol(symbol,.fof)
      case (_, PRLC_CNF):
        self = Tptp.Symbol(symbol,.cnf)
      case (_, PRLC_INCLUDE):
        self = Tptp.Symbol(symbol,.include)

      case (_, PRLC_ROLE):
        self = Tptp.Symbol(symbol,.role)
      case (_, PRLC_ANNOTATION):
        self = Tptp.Symbol(symbol,.annotation)

      case ("!", _):
        assert (type == PRLC_QUANTIFIER)
        self = Tptp.Symbol(symbol,.universal)
      case ("?", _):
        assert (type == PRLC_QUANTIFIER)
        self = Tptp.Symbol(symbol,.existential)

      case ("|", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.disjunction)
      case ("&", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.conjunction)
      case ("=>", _):
        assert (type == PRLC_CONNECTIVE)
        self = Tptp.Symbol(symbol,.implication)
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
        self = Tptp.Symbol(symbol,.function)
      case (_, PRLC_VARIABLE):
        self = Tptp.Symbol(symbol,.variable)

      default:
        self = Tptp.Symbol(symbol,.undefined)
    }
  }
}
