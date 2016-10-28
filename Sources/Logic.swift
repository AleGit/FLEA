protocol LogicExpr {

  // FIXME: those two exist to enable simplifying operators
  var mkTop : Self { get }
  var mkBot : Self { get }

  var isTrue : Bool { get }
  var isFalse : Bool { get }
  var isZero : Bool { get }

  static func ==(_ s: Self, _ t: Self) -> Bool
  static func !=(_ s: Self, _ t: Self) -> Bool

  // logical operators
  func not() -> Self
  func and(_ t: Self) -> Self
  func or(_ t: Self) -> Self
  func implies(_ t: Self) -> Self
  func iff(_ t: Self) -> Self
  func xor(_ t: Self) -> Self
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

  func evalBool(_ term: Expr) -> Bool?
  func evalInt(_ term: Expr) -> Int?
	func implies(formula: Expr) -> Bool
	func selectIndex<C: Collection>(literals: C) -> Int?
    where C.Iterator.Element == Expr
}

protocol LogicContext {
  associatedtype ExprType
  associatedtype Model : LogicModel
  typealias Expr = Model.Expr

  init()

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


protocol OptLogicContext : LogicContext {
  init(optimize opt: Bool)
  func maximize(_ expr: Expr) -> Int?
  func minimize(_ expr: Expr) -> Int?
  func push()
  func pop()
}


prefix operator !
prefix func !<E:LogicExpr>(_ s : E) -> E {
  guard !s.isTrue else { return s.mkBot }
  guard !s.isFalse else { return s.mkTop }
  return s.not()
}

infix operator ⋀: LogicalConjunctionPrecedence
func ⋀<E:LogicExpr>(_ s : E, _ t: E) -> E {
  guard !s.isTrue && s != t else { return t }
  guard !t.isTrue else { return s }
  guard !s.isFalse && !t.isFalse else { return s.mkBot }
  return s.and(t)
}

infix operator ⋁: LogicalDisjunctionPrecedence
func ⋁<E:LogicExpr>(_ s : E, _ t: E) -> E {
  guard !s.isFalse && s != t else { return t }
  guard !t.isFalse else { return s }
  guard !s.isTrue && !t.isTrue else { return s.mkTop }
  return s.or(t)
}

infix operator ⟹: LogicalDisjunctionPrecedence
func ⟹<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.implies(t)
}

infix operator ⟺: LogicalDisjunctionPrecedence
func ⟺<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.iff(t)
}

infix operator ⊕: LogicalDisjunctionPrecedence
func ⊕<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.xor(t)
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

infix operator +: AdditionPrecedence
func +<E:LogicExpr>(_ s : E, _ t: E) -> E {
  return s.add(t)
}

func ite<E:LogicExpr>(_ c: E, _ t: E, _ f: E) -> E {
  guard !c.isTrue else { return t }
  guard !c.isFalse else { return f }
  return c.ite(t, f)
}
