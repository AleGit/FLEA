import CTptpParsing

extension Tptp {
  enum Symbol : Hashable {
    case Undefined(String)

    /// <TPTP_file>
    case File(String)

    /// <fof_annotated>
    case Fof(String)
    /// <cnf_annotated>
    case Cnf(String)
    /// <include>
    case Include(String)    // file name

    case Name(String)

    case Role(String)
    case Annotation(String)

    case Universal(String)    // ! X Y s
    case Existential(String)  // ? X Y s

    case Negation(String)     // ~ s
    case Disjunction(String)  // s | t ...
    case Conjunction(String)  // s & t ...
    case Implication(String)  // s => t

    case Equation(String)   // s = t
    case Inequation(String) // s != t

    case Predicate(String)  // predicates and propositions
    case Function(String)   // functions and constants
    case Variable(String)   // variables
  }
}

extension Tptp.Symbol {
  init(symbol:String, type:PRLC_TREE_NODE_TYPE) {
    switch (symbol,type) {

      case (_, PRLC_FILE):
        self = .File(symbol)

      case (_, PRLC_FOF):
        self = .Fof(symbol)
      case (_, PRLC_CNF):
        self = .Cnf(symbol)
      case (_, PRLC_INCLUDE):
        self = .Include(symbol)

      case (_, PRLC_ROLE):
        self = .Role(symbol)
      case (_, PRLC_ANNOTATION):
        self = .Annotation(symbol)

      case ("!", _):
        assert (type == PRLC_QUANTIFIER)
        self = .Universal(symbol)
      case ("?", _):
        assert (type == PRLC_QUANTIFIER)
        self = .Existential(symbol)

      case ("|", _):
        assert (type == PRLC_CONNECTIVE)
        self = .Disjunction(symbol)
      case ("&", _):
        assert (type == PRLC_CONNECTIVE)
        self = .Conjunction(symbol)
      case ("=>", _):
        assert (type == PRLC_CONNECTIVE)
        self = .Implication(symbol)
      case ("~", _):
        assert (type == PRLC_CONNECTIVE)
        self = .Negation(symbol)

      case ("=", _):
        assert (type == PRLC_EQUATIONAL)
        self = .Equation(symbol)
      case ("!=", _):
        assert (type == PRLC_EQUATIONAL)
        self = .Inequation(symbol)

      case (_, PRLC_PREDICATE):
        self = .Predicate(symbol)

      case (_, PRLC_FUNCTION):
        self = .Function(symbol)
      case (_, PRLC_VARIABLE):
        self = .Variable(symbol)

      default:
        self = .Undefined(symbol)
    }
  }
}

extension Tptp.Symbol {
  var symbol : String {
    switch(self) {
      case .Undefined(let string):
        return string
      case .File(let string):
        return string
      case .Fof(let string):
        return string
      case .Cnf(let string):
        return string
      case .Include(let string):
        return string
      case .Name(let string):
        return string
      case .Role(let string):
        return string
      case .Annotation(let string):
        return string

      case .Universal(let string):
        return string
      case .Existential(let string):
        return string
      case .Negation(let string):
        return string
      case .Disjunction(let string):
        return string
      case .Conjunction(let string):
        return string
      case .Implication(let string):
        return string
      case .Equation(let string):
        return string
      case .Inequation(let string):
        return string
      case .Predicate(let string):
        return string
      case .Function(let string):
        return string
      case .Variable(let string):
        return string
      }
  }

  var hashValue : Int {
    return self.symbol.hashValue
  }
}

func ==(lhs:Tptp.Symbol, rhs:Tptp.Symbol) -> Bool {
  guard lhs.symbol == rhs.symbol else { return false }

  return true
}
