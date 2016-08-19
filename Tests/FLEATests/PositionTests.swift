import XCTest

@testable import FLEA

public class PositionTests : FleaTestCase {
  static var allTests : [(String, (PositionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func check<N:Node>(
    _ term:N,
    _ expected:[Position],
    _ message:String = "",
    _ file: String = #file,
    _ function : String = #function,
    _ line : Int = #line
  ) {
    let actual = term.positions
    #if os(OSX)
    XCTAssertEqual(actual,expected,"\n\(nok):\(line) \(term).positions = \(actual) ≠ \(expected)")
    #endif
  }

  func testBasics() {
    check(Q.X, [ε])
    check(Q.fXY, [ε,[0],[1]])
    check(Q.gXYZ, [ε,[0],[1],[2]])
    check(Q.hX, [ε,[0]])
    check(Q.ffaaZ, [ε,[0],[0,0],[0,1],[1]])

    XCTAssertEqual(Q.ffaaZ[ε],Q.ffaaZ)
    XCTAssertEqual(Q.ffaaZ[[0]],Q.faa)
    XCTAssertEqual(Q.ffaaZ[[0,0]],Q.a)
    XCTAssertEqual(Q.ffaaZ[[0,1]],Q.a)
    XCTAssertEqual(Q.ffaaZ[[1]],Q.Z)

  }
}
