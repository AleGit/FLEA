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
      XCTFail("\(Nodes.X) =?= \(Nodes.Y) failed.")
      return
    }
    var expected = [Nodes.X : Nodes.Y]
    XCTAssertEqual(X_Y, expected, "\(X_Y) ≠ \(expected)" )

    XCTAssertNil(Nodes.X =?= Nodes.fXY, "\(Nodes.X) =/= \(Nodes.fXY)"  )
    XCTAssertNil(Nodes.Y =?= Nodes.fXY, "\(Nodes.Y) =/= \(Nodes.fXY)"  )

    guard let Z_fXY = Nodes.Z =?= Nodes.fXY else {
      XCTFail("\(Nodes.Z) =?= \(Nodes.fXY) failed.")
      return
    }
    expected = [Nodes.Z : Nodes.fXY]
    XCTAssertEqual(Z_fXY, expected, "\(X_Y) ≠ \(expected)" )

    let fYX = Nodes.fXY * [Nodes.X:Nodes.Y,Nodes.Y:Nodes.X]

    guard let mgu = Nodes.fXY =?= fYX else {
      XCTFail("\(Nodes.Z) =?= \(Nodes.fXY) failed.")
      return
    }
    expected = [Nodes.X : Nodes.Y]
    XCTAssertEqual(mgu, expected, "\(mgu) ≠ \(expected)" )


  }
}
