import XCTest

@testable import FLEA

public class SubstitutionTests : XCTestCase {
  static var allTests : [(String, (SubstitutionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func testBasics() {
    XCTAssertTrue(true)

    let X_a = [Nodes.X : Nodes.a]
    let Y_b = [Nodes.Y: Nodes.b]
    let Z_c = [Nodes.Z : Nodes.c]
    let XYZ_abc = [Nodes.X : Nodes.a, Nodes.Y: Nodes.b, Nodes.Z : Nodes.c]

    guard let lc = (X_a * Y_b), let lcombined = lc * Z_c else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }

    XCTAssertEqual(XYZ_abc,lcombined,"\(XYZ_abc) ≠ \(lcombined)")

    guard let rc = (Y_b * Z_c), let rcombined = X_a * rc else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }

    XCTAssertEqual(XYZ_abc,rcombined,"\(XYZ_abc) ≠ \(rcombined)")
  }
}
