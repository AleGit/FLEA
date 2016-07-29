import CTptpParsing

// MARK: - protocol -

protocol Symbolable : Hashable {

  /// the empty symbol
  static var empty: Self { get }

  var string : String { get }
  var type : Tptp.SymbolType { get }

  init(of node:TreeNodeRef)

  /// Initialze a symbol with a node of the abstract syntax tree.
}

// MARK: - String -

/// A string is symbolable
extension String : Symbolable {
  static var empty : String { return "" }

  var string : String { return self }
  var type: Tptp.SymbolType {
    switch self {
      case "!":
        return .universal
      case "?":
        return .existential
      case "~":
        return .negation
      case "|":
        return .disjunction
      case "&":
        return .conjunction
      case "=>":
        return .implication
      case "=":
        return .equation
      case "!=":
        return .inequation

      default:
        return .undefined
    }
  }
}

extension String {
  init(of node:TreeNodeRef) {
    let s = node.symbol ?? "n/a"
    // TODO: insert symbol into symbol table
    self = s
  }
}

// MARK: - Tptp.Symbol

extension Tptp {
  enum SymbolType {
    case undefined

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

  struct Symbol : Hashable, CustomDebugStringConvertible {
    let string : String
    let type : SymbolType

    init(_ string: String, _ type: SymbolType ) {
      self.string = string
      self.type = type
    }
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

// MARK: Int
//



// struct SymbolTable<String,Symbol:Symbolable> {
//   var symbols = [String : S]()
//   var strings = [String]
//
//   mutating func insert(_ string: String) -> Symbol {
//     if let symbol = symbols[string] {
//       return symbol
//     }
//     let count = strings.count
//     strings.append(string)
//     symbols[string] = count
//   }
//
//   subscript(value:Int) -> String {
//     guard 0 <= value && value < strings.count else {
//       return String.empty
//     }
//     return strings[value]
//   }
// }

extension Int : Symbolable {
  static var empty : Int { return 0 }

  var string : String { return "x/a" }
  var type : Tptp.SymbolType {
    return .undefined
  }

}

extension Int {
  init(of node:TreeNodeRef) {
    guard let _ = node.symbol else {
      self = 0
      return
    }
    self = 1
  }


}
