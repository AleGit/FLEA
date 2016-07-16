import CTptpParsing

extension Tptp {
  enum Symbol : Hashable {
    case Undefined
  case Name(String)
  case Equational(String)
  case Predicate(String)
  case Function(String)
  case Variable(String)
  }
}

// extension TypeSymbol {
//   var name : Symbol {
//
//   }
// }

extension Tptp.Symbol {
  init(type:PRLC_TREE_NODE_TYPE, symbol:String) {
    switch type {
      case PRLC_EQUATIONAL:
        self = .Equational(symbol)
      case PRLC_PREDICATE:
        self = .Predicate(symbol)
      case PRLC_FUNCTION:
        self = .Function(symbol)
      case PRLC_VARIABLE:
        self = .Variable(symbol)
      default:
        self = .Name(symbol)
    }
  }
}

extension Tptp.Symbol {
  var symbol : String {
    switch(self) {
      case (.Name(let string)):
        return string
      case (.Equational(let string)):
        return string
      case (.Predicate(let string)):
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
    (.Predicate, .Predicate),
    (.Equational, .Equational),
    (.Function, .Function),
    (.Variable, .Variable):
    return true
    default:
      return false

  }
}
