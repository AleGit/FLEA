protocol LogicExpr {
  // logical operators
  func not() -> Self
  func and(_ t: Self) -> Self
  func or(_ t: Self) -> Self
  func implies(_ t: Self) -> Self
  func ite(_ t: Self, _ f: Self) -> Self

  // arithmetic operators
  func eq(_ t: Self) -> Self
  func neq(_ t: Self) -> Self
  func gt(_ t: Self) -> Self
  func ge(_ t: Self) -> Self
  func add(_ t: Self) -> Self

  // deconstruct terms
  var children : [Self] { get }
}

protocol LogicModel {
  associatedtype Expr : LogicExpr

  func evalBool(_ term: Expr) -> Bool
  func evalInt(_ term: Expr) -> Int
	func implies(formula: Expr) -> Bool
	func selectIndex<C: Collection>(literals: C) -> Int?
    where C.Iterator.Element == Expr
}

protocol LogicContext {
  associatedtype ExprType
  associatedtype Model : LogicModel
  typealias Expr = Model.Expr

	static var versionString: String { get }

  // types
  var bool_type : ExprType { get }
  var int_type : ExprType { get }
  var free_type : ExprType { get }

  // create terms
  var mkTop : Expr { get }
  var mkBot : Expr { get }
  func mkAnd(_ ts: [Expr]) -> Expr
  func mkOr(_ ts: [Expr]) -> Expr
  func mkBoolVar(_ name: String) -> Expr
  func mkIntVar(_ name: String) -> Expr
  func constant(_ name: String, _ type: ExprType) -> Expr
  func app(_ symbol: String, _ args: [Expr], _ range: ExprType) -> Expr
  func mkNum(_ n: Int) -> Expr
  var 🚧 : Expr { get }

  // assertion and checking
  func ensure(_ formula: Expr)
  func ensureCheck(formula: Expr) -> Bool
	var isSatisfiable: Bool { get }
  var model: Model? { get }
}


prefix operator !
prefix func !<E:LogicExpr>(_ s : E) -> E {
  return s.not()
}

infix operator ⋀: LogicalConjunctionPrecedence
func ⋀<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.and(t)
}

infix operator ⋁: LogicalDisjunctionPrecedence
func ⋁<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.or(t)
}

infix operator ==: ComparisonPrecedence
func ==<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.eq(t)
}

infix operator !=: ComparisonPrecedence
func !=<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.neq(t)
}

infix operator ≻: ComparisonPrecedence
func ≻<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.gt(t)
}

infix operator ≽: ComparisonPrecedence
func ≽<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.ge(t)
}
