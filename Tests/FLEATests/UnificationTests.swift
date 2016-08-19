import XCTest

@testable import FLEA

public class UnificationTests : FleaTestCase {
  static var allTests : [(String, (UnificationTests) -> () throws -> Void)] {
    return [
    ("testUnifiable", testUnifiable),
    ("testNotUnifiable", testNotUnifiable)
    ]
  }

  func check<S:Substitution,N:Node> (
    _ lhs:N,
    _ rhs:N,
    _ expected:S? = nil,
    _ message:String = "",
    _ file: String = #file,
    _ function: String = #function,
    _ line : Int = #line
  )
  where S.K==N, S.V==N, S:Equatable, N.Symbol:StringSymbolable,
  S.Iterator == DictionaryIterator<N,N> {
    let actual : S? = lhs =?= rhs

    // XCTFail("\n\(nok) \(message).\(file).\(function).\(line)")

    XCTAssertEqual("\(S.self)","Instantiator<SmartNode>")

    switch (actual, expected) {
      case (.none, .none):
          break
      case (.none, _):
        XCTFail("\n\(nok):\(line) \(lhs) =?= \(rhs) => nil ≠ \(expected!) \(message)")
      case (_, .none):
        XCTFail("\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ nil \(message)")
      default:
        XCTAssertEqual(actual! , expected!, "\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ \(expected!) \(message)")
        // XCTAssertEqual(actual!.description , expected!.description, "\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ \(expected!) \(message)")
    }
  }

  func testUnifiable() {

    check( Q.X, Q.Y, [Q.X : Q.Y] as Instantiator,"A")

    check( Q.Z, Q.fXY, [Q.Z : Q.fXY] as Instantiator,"B")
    check( Q.fXY, Q.Z, [Q.Z : Q.fXY] as Instantiator,"C")

    check( Q.fXY, Q.ffaaZ, [Q.X:Q.faa, Q.Y:Q.Z] as Instantiator,"D")
    check( Q.ffaaZ, Q.fXY, [Q.X:Q.faa, Q.Z:Q.Y] as Instantiator,"E")

    check( Q.fXX, Q.fYZ, [Q.X:Q.Z, Q.Y:Q.Z]  as Instantiator,"F")
    check( Q.fYZ, Q.fXX, [Q.Y:Q.X, Q.Z:Q.X] as Instantiator,"G")

    check( Q.fXX, Q.fXZ, [Q.X:Q.Z]  as Instantiator,"H")
    check( Q.fXZ, Q.fXX, [Q.Z:Q.X] as Instantiator,"I")
  }

  func testNotUnifiable() {
    check( Q.a, Q.b, nil as Instantiator?)

    check( Q.X, Q.fXY, nil as Instantiator?)
    check( Q.Y, Q.fXY, nil as Instantiator?)

  }
}
