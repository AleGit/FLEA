import XCTest

@testable import FLEA

public class UnificationTests : XCTestCase {
  static var allTests : [(String, (UnificationTests) -> () throws -> Void)] {
    return [
    ("testUnifiable", testUnifiable),
    ("testNotUnifiable", testNotUnifiable)
    ]
  }

  func check<N:FLEA.Node>(_ l:N, _ r:N, _ expected:[N:N]? = nil, _ label:String) {
    let actual = l =?= r

    switch (actual, expected) {
      case (.none, .none):
        break
      case (.none, _):
        XCTFail("\n \(l) =?= \(r) => nil ≠ \(expected!) \(label)")
      case (_, .none):
        XCTFail("\n \(l) =?= \(r) => \(actual!) ≠ nil \(label)")
      default:
        XCTAssertEqual(actual! , expected!, "\n \(l) =?= \(r) => \(actual!) ≠ \(expected!) \(label)")
    }
  }

  func testUnifiable() {
    check( Q.X, Q.Y, [Q.X : Q.Y],"\(#line) \(#file) \(nok)")

    check( Q.Z, Q.fXY, [Q.Z : Q.fXY],"\(#line) \(#file) \(nok)")
    check( Q.fXY, Q.Z, [Q.Z : Q.fXY],"\(#line) \(#file) \(nok)")

    check( Q.fXY, Q.ffaaZ, [Q.X:Q.faa, Q.Y:Q.Z],"\(#line) \(#file) \(nok)")
    check( Q.ffaaZ, Q.fXY, [Q.X:Q.faa, Q.Z:Q.Y],"\(#line) \(#file) \(nok)")

    check( Q.fXX, Q.fYZ, [Q.X:Q.Z, Q.Y:Q.Z], "\(#line) \(#file) \(nok)")
    check( Q.fYZ, Q.fXX, [Q.Y:Q.X, Q.Z:Q.X], "\(#line) \(#file) \(nok)")

    check( Q.fXX, Q.fXZ, [Q.X:Q.Z], "\(#line) \(#file) \(nok)")
    check( Q.fXZ, Q.fXX, [Q.Z:Q.X], "\(#line) \(#file) \(nok)")
  }

  func testNotUnifiable() {
    check( Q.a, Q.b, nil, "\(#line) \(#file) \(nok)")

    check( Q.X, Q.fXY, nil, "\(#line) \(#file) \(nok)")
    check( Q.Y, Q.fXY, nil, "\(#line) \(#file) \(nok)")

  }
}
