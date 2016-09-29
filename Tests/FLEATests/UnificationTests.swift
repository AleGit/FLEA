import XCTest

@testable import FLEA

public class UnificationTests: FleaTestCase {
  static var allTests: [(String, (UnificationTests) -> () throws -> Void)] {
    return [
    ("testUnifiable", testUnifiable),
    ("testNotUnifiable", testNotUnifiable),
    ("testSuffixing", testSuffixing),
    ("testSuffixing", testNormalizing)
    ]
  }

  func check<S: Substitution, N: Node> (
    _ lhs:N,
    _ rhs:N,
    _ expected:S? = nil,
    _ message:String = "",
    _ file: String = #file,
    _ function: String = #function,
    _ line : Int = #line
  )
  where S.K==N, S.V==N, S:Equatable, N.Symbol:StringSymbolable,
  S.Iterator == DictionaryIterator<N, N> {
    let actual: S? = lhs =?= rhs

    XCTAssertEqual("\(S.self)", "Instantiator<SmartNode>")

    switch (actual, expected) {
      case (.none, .none):
          break
      case (.none, _):
        XCTFail("\n\(nok):\(line) \(lhs) =?= \(rhs) => nil ≠ \(expected!) \(message)")
      case (_, .none):
        XCTFail("\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ nil \(message)")
      default:
        XCTAssertEqual(actual!, expected!,
        "\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ \(expected!) \(message)")
    }
  }

  func testUnifiable() {

    check( Q.X, Q.Y, [Q.X : Q.Y] as Instantiator, "A")

    check( Q.Z, Q.fXY, [Q.Z : Q.fXY] as Instantiator, "B")
    check( Q.fXY, Q.Z, [Q.Z : Q.fXY] as Instantiator, "C")

    check( Q.fXY, Q.ffaaZ, [Q.X:Q.faa, Q.Y:Q.Z] as Instantiator, "D")
    check( Q.ffaaZ, Q.fXY, [Q.X:Q.faa, Q.Z:Q.Y] as Instantiator, "E")

    check( Q.fXX, Q.fYZ, [Q.X:Q.Z, Q.Y:Q.Z]  as Instantiator, "F")
    check( Q.fYZ, Q.fXX, [Q.Y:Q.X, Q.Z:Q.X] as Instantiator, "G")

    check( Q.fXX, Q.fXZ, [Q.X:Q.Z]  as Instantiator, "H")
    check( Q.fXZ, Q.fXX, [Q.Z:Q.X] as Instantiator, "I")
  }

  func testNotUnifiable() {
    check( Q.a, Q.b, nil as Instantiator?)

    check( Q.X, Q.fXY, nil as Instantiator?)
    check( Q.Y, Q.fXY, nil as Instantiator?)

  }

  func testSuffixing() {
    let X1 = Q.X.appending(suffix:1)
    XCTAssertEqual("X_1", "\(X1)", nok)

    guard let mgu = Q.X =?= X1 else {
      XCTFail(nok)
      return
    }
    XCTAssertEqual([Q.X:X1], mgu, nok)

    let X2 = Q.X * mgu
    let X3 = X1 * mgu

    XCTAssertEqual(X2, X3, nok)

    XCTAssertEqual("X_1", "\(X2)", nok)
    XCTAssertEqual("X_1", "\(X3)", nok)

    let X4 = X2.normalizing()
    let X5 = X2.normalizing()

     XCTAssertEqual(Q.X, X4, nok)
     XCTAssertEqual(Q.X, X5, nok)

     XCTAssertEqual("X", "\(X4)", nok)
    XCTAssertEqual("X", "\(X5)", nok)

  }

  func testNormalizing() {
    let t0 = "p(f(X_1))|q(X_2)|r(X_1)" as Q.Node

    XCTAssertEqual("(p(f(X))|q(X_2)|r(X))", "\(t0.normalizing())", nok)

  }
}
