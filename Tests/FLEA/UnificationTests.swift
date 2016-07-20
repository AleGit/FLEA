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
      case (.none, let e0):
        XCTFail("\n \(l) =?= \(r) => nil ≠ \(e0) \(label)")
      case (let a0, .none):
        XCTFail("\n \(l) =?= \(r) => \(a0) ≠ nil \(label)")
      case (let a, let e):
        XCTAssertEqual(a! , e!, "\n \(l) =?= \(r) => \(a) ≠ \(e) \(label)")
    }
  }

  func testUnifiable() {
    check( Nodes.X, Nodes.Y, [Nodes.X : Nodes.Y],"\(#line) \(#file) \(nok)")

    check( Nodes.Z, Nodes.fXY, [Nodes.Z : Nodes.fXY],"\(#line) \(#file) \(nok)")
    check( Nodes.fXY, Nodes.Z, [Nodes.Z : Nodes.fXY],"\(#line) \(#file) \(nok)")

    check( Nodes.fXY, Nodes.ffaaZ, [Nodes.X:Nodes.faa,Nodes.Y:Nodes.Z],"\(#line) \(#file) \(nok)")
    check( Nodes.ffaaZ, Nodes.fXY, [Nodes.X:Nodes.faa,Nodes.Z:Nodes.Y],"\(#line) \(#file) \(nok)")
  }

  func testNotUnifiable() {
    check( Nodes.a, Nodes.b, nil, "\(#line) \(#file) \(nok)")
    check( Nodes.X, Nodes.fXY, nil, "\(#line) \(#file) \(nok)")
    check( Nodes.Y, Nodes.fXY, nil, "\(#line) \(#file) \(nok)")

  }
}
