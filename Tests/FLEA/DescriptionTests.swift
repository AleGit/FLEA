import XCTest

@testable import FLEA

public class DescriptionTests : XCTestCase {

  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node {
    static var pool = WeakSet<N>()
    static var symbols = FLEA.StringIntegerTable<Int>()

    var symbol = Int.max
    var nodes : [N]? = nil
    var folks =  WeakSet<N>()

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription
  }

  static var allTests : [(String, (DescriptionTests) -> () throws -> Void)] {
    return [
      ("testDescription", testDescription),
      ("testDebugDescription", testDebugDescription)
    ]
  }

  func testDescription() {
    let a = N(c:"a")
    let X = N(v:"X")
    let fXa = N(f:"f",[X,a])

    XCTAssertEqual("a", a.description,nok)
    XCTAssertEqual("X", X.description,nok)

    XCTAssertEqual("f(X,a)", fXa.description,nok)



  }

  func testDebugDescription() {
    let a = N(c:"a")
    let X = N(v:"X")
    let fXa = N(f:"f",[X,a])
    // let equals = Tptp.N.Symbol("=",.equation)

    XCTAssertEqual("1-a-function(0)", a.debugDescription,nok)
    XCTAssertEqual("2-X-variable", X.debugDescription,nok)

    XCTAssertEqual("3-f-function(2)(2-X-variable,1-a-function(0))", fXa.debugDescription,nok)

    //
    // XCTAssertEqual("f(X,Y)", Q.fXY.debugDescription,nok)
    // XCTAssertEqual("g(X,Y,Z)", Q.gXYZ.debugDescription,nok)
    // XCTAssertEqual("h(X)", Q.hX.debugDescription,nok)
  }
}
