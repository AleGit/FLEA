import XCTest

@testable import FLEA

public class DescriptionTests : XCTestCase {
  static var allTests : [(String, (DescriptionTests) -> () throws -> Void)] {
    return [
      ("testDescription", testDescription)
    ]
  }

  func testDescription() {
    let a = Tptp.KinNode(c:"a")
    let X = Tptp.KinNode(v:"X")
    let fXa = Tptp.KinNode(f:"f",[X,a])

    XCTAssertEqual("a", a.description,nok)
    XCTAssertEqual("X", X.description,nok)

    XCTAssertEqual("f(X,a)", fXa.description,nok)



  }

  func testDebugDescription() {
    let a = Tptp.KinNode(c:"a")
    let X = Tptp.KinNode(v:"X")
    let fXa = Tptp.KinNode(f:"f",[X,a])
    // let equals = Tptp.KinNode.Symbol("=",.equation)

    XCTAssertEqual("2-a-function", a.debugDescription,nok)
    XCTAssertEqual("3-X-variable", X.debugDescription,nok)

    XCTAssertEqual("4-f-function(\"3-X-variable\",\"2-a-function\")", fXa.debugDescription,nok)

print(globalIntSymbolTable)
    //
    // XCTAssertEqual("f(X,Y)", Q.fXY.debugDescription,nok)
    // XCTAssertEqual("g(X,Y,Z)", Q.gXYZ.debugDescription,nok)
    // XCTAssertEqual("h(X)", Q.hX.debugDescription,nok)
  }
}
