import XCTest

@testable import FLEA

public class PositionTests : XCTestCase {
  static var allTests : [(String, (PositionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func check<N:FLEA.Node>(
    _ term:N,
    _ expected:[Position],
    _ message:String = "",
    _ file: String = #file,
    _ function : String = #function,
    _ line : Int = #line
  ) {
    let actual = term.positions
    XCTAssertEqual(actual,expected,"\n\(nok):\(line) \(term).positions = \(actual) ≠ \(expected)")
  }

  func testBasics() {
    check(Q.X, [ε], "\(#line)")
    check(Q.fXY, [ε,[0],[1]], "\(#line)")

    check(Q.fXY, [ε,[0],[1]], "\(#line)")


    let a = [1,5,6]
    print (a, a.dynamicType)

  }
}
