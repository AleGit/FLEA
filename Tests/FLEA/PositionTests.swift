import XCTest

@testable import FLEA

public class PositionTests : XCTestCase {
  static var allTests : [(String, (PositionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func check<N:FLEA.Node>(_ t:N, _ expected:[Position], _ label:String) {
    let actual = t.positions
    XCTAssertEqual(actual,expected,"\(t).positions \(nok) \(label)")
  }

  func testBasics() {
    check(Q.X, [ε], "\(#line)")
    check(Q.fXY, [ε,[0],[1]], "\(#line)")


  }
}
