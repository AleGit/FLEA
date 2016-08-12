import XCTest

@testable import FLEA

public class DictionaryUnificationTests : XCTestCase {
  static var allTests : [(String, (DictionaryUnificationTests) -> () throws -> Void)] {
    return [
    ("testUnifiable", testUnifiable),
    ("testNotUnifiable", testNotUnifiable)
    ]
  }

  func check<N:FLEA.Node where N.Symbol:StringSymbolable>(
    _ lhs:N,
    _ rhs:N,
    _ expected:[N:N]? = nil,
    _ message:String = "",
    _ file: String = #file,
    _ function: String = #function,
    _ line : Int = #line
  ) {
    let actual = lhs =?= rhs

    // XCTFail("\n\(nok) \(message).\(file).\(function).\(line)")

    switch (actual, expected) {
      case (.none, .none):
        break
      case (.none, _):
        XCTFail("\n\(nok):\(line) \(lhs) =?= \(rhs) => nil ≠ \(expected!) \(message)")
      case (_, .none):
        XCTFail("\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ nil \(message)")
      default:
        print("\(actual!),\(expected!)")
        XCTAssertEqual(actual! , expected!, "\n\(nok):\(line) \(lhs) =?= \(rhs) => \(actual!) ≠ \(expected!) \(message)")
    }
  }

  func testUnifiable() {

    check( Q.X, Q.Y, [Q.X : Q.Y])

    check( Q.Z, Q.fXY, [Q.Z : Q.fXY])
    check( Q.fXY, Q.Z, [Q.Z : Q.fXY])

    check( Q.fXY, Q.ffaaZ, [Q.X:Q.faa, Q.Y:Q.Z])
    check( Q.ffaaZ, Q.fXY, [Q.X:Q.faa, Q.Z:Q.Y])

    check( Q.fXX, Q.fYZ, [Q.X:Q.Z, Q.Y:Q.Z])
    check( Q.fYZ, Q.fXX, [Q.Y:Q.X, Q.Z:Q.X])

    check( Q.fXX, Q.fXZ, [Q.X:Q.Z])
    check( Q.fXZ, Q.fXX, [Q.Z:Q.X])
  }

  func testNotUnifiable() {
    check( Q.a, Q.b)

    check( Q.X, Q.fXY, nil)
    check( Q.Y, Q.fXY, nil)

  }
}
