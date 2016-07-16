import CTptpParsing

enum PredicateType {
}

enum ConnectiveType {
}

extension Tptp {
  enum SymbolType {
    case Undefined

    /* names */

    case File
    case Fof
    case Cnf
    case Include
    case Name
    case Role
    case Annoation

    /* connectives */

    case Universal
    case Existential

    case Negation
    case Disjunction
    case Conjunction
    case Implication

    /*  */

      case Equation
      case Inequation
      case Predicate

      case Function
      case Variable


  }




  enum Symbol : Hashable {


    case Undefined

    /// <TPTP_file>
    // case File(String)

    /// <cnf_annotated>, <fof_annotated>
    //case Annotated(String)

    //case Include(String)
    // file, fof, cnf, inlcude, name, role, annoations
    case Name(String, SymbolType)

    /// Quantifiers and connectives
    case Connective(String, SymbolType)

    /// Equationals, Predicates and Propositions
    case Predicate(String, SymbolType)

    /// Function and Constants
    case Function(String)

    /// Variables
    case Variable(String)
  }
}

// extension TypeSymbol {
//   var name : Symbol {
//
//   }
// }

extension Tptp.Symbol {
  init(symbol:String, type:PRLC_TREE_NODE_TYPE) {
    switch (symbol,type) {
      case (_, PRLC_FILE):
        self = .Name(symbol, .File)
      case (_, PRLC_FOF):
        self = .Name(symbol, .Fof)
      case (_, PRLC_CNF):
        self = .Name(symbol, .Cnf)
      case (_, PRLC_INCLUDE):
        self = .Name(symbol, .Include)
      case (_, PRLC_ROLE):
        self = .Name(symbol, .Role)
      case (_, PRLC_ANNOTATION):
        self = .Name(symbol, .Annoation)

      case ("!", _):
        self = .Connective(symbol, .Universal)
      case ("?", _):
        self = .Connective(symbol, .Existential)

      case ("|", _):
        self = .Connective(symbol, .Disjunction)
      case ("&", _):
        self = .Connective(symbol, .Conjunction)
      case ("=>", _):
        self = .Connective(symbol, .Implication)
      case ("~", _):
        self = .Connective(symbol, .Negation)

      case ("=", _):
        self = .Predicate(symbol, .Equation)
      case ("!=", _):
        self = .Predicate(symbol, .Inequation)

      case (_, PRLC_PREDICATE):
        self = .Predicate(symbol,.Predicate)

      case (_, PRLC_FUNCTION):
        self = .Function(symbol)
      case (_, PRLC_VARIABLE):
        self = .Variable(symbol)

      default:
        self = .Name(symbol,.Undefined)
    }
  }
}

extension Tptp.Symbol {
  var symbol : String {
    switch(self) {
      case (.Name(let string, _)):
        return string
      case (.Connective(let string, _)):
        return string
      case (.Predicate(let string,_)):
        return string
      case (.Function(let string)):
        return string
      case (.Variable(let string)):
        return string
      default:
        return "n/a"
      }
  }

  var hashValue : Int {
    return self.symbol.hashValue
  }
}

func ==(lhs:Tptp.Symbol, rhs:Tptp.Symbol) -> Bool {
  guard lhs.symbol == rhs.symbol else { return false }
  switch (lhs,rhs) {
    case (.Name, .Name),
    (.Connective,.Connective),
    (.Predicate, .Predicate),
    (.Function, .Function),
    (.Variable, .Variable):
    return true
    default:
      return false

  }
}
