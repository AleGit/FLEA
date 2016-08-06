import XCTest

@testable import FLEA

public class DescriptionTests : XCTestCase {

  private final class KinNode : FLEA.KinNode, FLEA.SymbolTableUser {
    static var pool = WeakSet<KinNode>()
    static var symbols = FLEA.IntegerSymbolTable<Int>()

    var symbol = Int.max
    var nodes : [KinNode]? = nil
    var folks =  WeakSet<KinNode>()

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
    let a = KinNode(c:"a")
    let X = KinNode(v:"X")
    let fXa = KinNode(f:"f",[X,a])

    XCTAssertEqual("a", a.description,nok)
    XCTAssertEqual("X", X.description,nok)

    XCTAssertEqual("f(X,a)", fXa.description,nok)



  }

  func testDebugDescription() {
    let a = KinNode(c:"a")
    let X = KinNode(v:"X")
    let fXa = KinNode(f:"f",[X,a])
    // let equals = Tptp.KinNode.Symbol("=",.equation)

    XCTAssertEqual("1-a-function", a.debugDescription,nok)
    XCTAssertEqual("2-X-variable", X.debugDescription,nok)

    XCTAssertEqual("3-f-function(\"2-X-variable\",\"1-a-function\")", fXa.debugDescription,nok)

    //
    // XCTAssertEqual("f(X,Y)", Q.fXY.debugDescription,nok)
    // XCTAssertEqual("g(X,Y,Z)", Q.gXYZ.debugDescription,nok)
    // XCTAssertEqual("h(X)", Q.hX.debugDescription,nok)
  }
}
