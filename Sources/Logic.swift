protocol Logic {
  associatedtype Term
  associatedtype TType
  associatedtype Model

  init()
  // types
  var bool_type : TType { get }
  var int_type : TType { get }
  var free_type : TType { get }

  // logical operators
  var top : Term { get }
  var bot : Term { get }
  func not(_ t: Term) -> Term
  func and(_ s : Term, _ t: Term) -> Term
  func and(_ ts: [Term]) -> Term
  func or(_ s: Term, _ t: Term) -> Term
  func or(_ ts: [Term]) -> Term
  func implies(_ s: Term, _ t: Term) -> Term
  func ite(_ c: Term, t: Term, f: Term) -> Term

  // arithmetic operators
  func eq(_ s: Term, _ t: Term) -> Term
  func neq(_ s: Term, _ t: Term) -> Term
  func gt(_ s: Term, _ t: Term) -> Term
  func ge(_ s: Term, _ t: Term) -> Term
  func add(_ s : Term, _ t: Term) -> Term

  // create terms
  func freshBoolVar(_ name: String) -> Term
  func freshIntVar(_ name: String) -> Term
  func getConst(_ name: String, _ type: TType) -> Term
  func getFun(_ name: String, _ domain: [TType], _ range: TType) -> Term
  func getApp(_ symbol: String, _ args: [Term], _ range: TType) -> Term
  var 🚧 : Term { get }

  // deconstruct terms
  func children(_ term: Term) -> [Term]

  // evaluation
  func evalBool(_ model: Model, _ term: Term) -> Bool
  func evalInt(_ model: Model, _ term: Term) -> Int
}
