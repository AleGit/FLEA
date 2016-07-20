import XCTest

@testable import FLEA

public class UnificationTests : XCTestCase {
  static var allTests : [(String, (UnificationTests) -> () throws -> Void)] {
    return [
    ("testUnificationBasics", testUnificationBasics)
    ]
  }

  func testUnificationBasics() {
    XCTAssertTrue(true)

    guard let X_Y = Nodes.X =?= Nodes.Y else {
      XCTFail("\(nok)  \(Nodes.X) =?= \(Nodes.Y) \(nok).")
      return
    }
    var expected = [Nodes.X : Nodes.Y]
    XCTAssertEqual(X_Y, expected, "\(X_Y) ≠ \(expected)" )

    XCTAssertNil(Nodes.X =?= Nodes.fXY, "\(Nodes.X) =x= \(Nodes.fXY) \(nok)"  )
    XCTAssertNil(Nodes.Y =?= Nodes.fXY, "\(Nodes.Y) =x= \(Nodes.fXY) \(nok)"  )

    guard let Z_fXY = Nodes.Z =?= Nodes.fXY else {
      XCTFail("\(nok) \(Nodes.Z) =?= \(Nodes.fXY) \(nok).")
      return
    }
    expected = [Nodes.Z : Nodes.fXY]
    XCTAssertEqual(Z_fXY, expected, "\(X_Y) ≠ \(expected) \(nok)" )

    let fYX = Nodes.fXY * [Nodes.X:Nodes.Y,Nodes.Y:Nodes.X]

    guard let fXY_fYX = Nodes.fXY =?= fYX else {
      XCTFail("\(nok)  \(Nodes.Z) =?= \(Nodes.fXY) \(nok).")
      return
    }
    expected = [Nodes.X : Nodes.Y]
    XCTAssertEqual(fXY_fYX, expected, "\(nok) \(fXY_fYX) ≠ \(expected) \(nok)" )


  }
  /// f(X,Y) =?= f(f(a,a),Z) => { X->f(a,a), Y->Z}

  func test_fXY_ffaaZ() {

    var expected = [Nodes.X : Nodes.faa, Nodes.Y:Nodes.Z]
    guard let fXY_ffaaZ = Nodes.fXY =?= Nodes.ffaaZ else {
      XCTFail("\(nok)  \(Nodes.fXY) =?= \(Nodes.ffaaZ) \(nok).")
      return
    }
    XCTAssertEqual(fXY_ffaaZ, expected, "\(nok) \(fXY_ffaaZ) ≠ \(expected)" )

    expected = [Nodes.X : Nodes.faa, Nodes.Z:Nodes.Y]
    guard let ffaaZ_fXY = Nodes.ffaaZ =?= Nodes.fXY else {
      XCTFail("\(nok)  \(Nodes.ffaaZ) =?= \(Nodes.fXY) \(nok).")
      return
    }
    XCTAssertEqual(ffaaZ_fXY, expected, "\(nok) \(ffaaZ_fXY) ≠ \(expected)" )

  }
}
