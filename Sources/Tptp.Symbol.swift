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

    case universal    // ! X Y ... s with implicit arity == 1..<∞
    case existential  // ? X Y ... s with implicit arity == 1..<∞

    case negation     // ~ s with implicit arity == 1
    case disjunction  // s | t ... with implicit arity == 0..<∞
    case conjunction  // s & t ... with implicit arity == 0..<∞

    case implication  // s => t with implicit arity == 2
    case reverseimpl  // s <= t with implicit arity == 2
    case bicondition // s <=> t with implicit arity == 2
    case xor  // <~> with implicit arity == 2
    case nand // ~& with implicit arity == 2
    case nor // ~| with implicit arity == 2

    // case gentzen // -->
    // case star // *
    // case plus // +

    // $true
    // $false

    case equation   // s = t with implicit arity == 2
    case inequation // s != t with implicit arity == 2

    case predicate(Int)  // predicates and propositions with symolb fixed arity

    case function(Int)   // functions and constants with symbol fixed arity
    case variable   // variables
  }
}

func ==(lhs:Tptp.SymbolType, rhs:Tptp.SymbolType) -> Bool {
  switch (lhs,rhs) {
    case (.file,.file),
      (.fof,.fof),
      (.cnf,.cnf),
      (.include,.include),
      (.name,.name),
      (.role,.role),
      (.annotation,.annotation),
      (.universal,.universal),
      (.existential,.existential),
      (.negation,.negation),
      (.disjunction,.disjunction),
      (.conjunction,.conjunction),
      (.implication,.implication),
      (.reverseimpl,.reverseimpl),
      (.bicondition,.bicondition),
      (.xor,.xor),
      (.nand,.nand),
      (.nor,.nor),
      (.equation,.equation),
      (.inequation,.inequation),
      (.variable,.variable):
      return true
    case (.predicate(let larity),.predicate(let rarity)):
      return larity == rarity
    case (.function(let larity),.function(let rarity)):
      return larity == rarity
    default:
      return false

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
        self = .predicate(node.childCount)

      case (_, PRLC_FUNCTION):
        self = .function(node.childCount)

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
