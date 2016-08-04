import XCTest

@testable import FLEA

public class DictionarySubstitutionTests : XCTestCase {
  static var allTests : [(String, (DictionarySubstitutionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func testBasics() {
    let X_a = [Q.X : Q.a]
    let Y_b = [Q.Y: Q.b]
    let Z_c = [Q.Z : Q.c]
    let XYZ_abc = [Q.X : Q.a, Q.Y: Q.b, Q.Z : Q.c]

    XCTAssertEqual("\(X_a.dynamicType)","Dictionary<SmartNode, SmartNode>")

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
