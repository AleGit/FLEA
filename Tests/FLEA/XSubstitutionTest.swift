import XCTest

@testable import FLEA

public class XSubstitutionTests : XCTestCase {
  static var allTests : [(String, (XSubstitutionTests) -> () throws -> Void)] {
    return [
      ("testSubstitutionBasics", testSubstitutionBasics)
    ]
  }

  func testSubstitutionBasics() {
    let X_a : Instantiator = [Q.X : Q.a]
    let Y_b : Instantiator = [Q.Y: Q.b]
    let Z_c : Instantiator = [Q.Z : Q.c]
    let XYZ_abc : Instantiator = [Q.X : Q.a, Q.Y: Q.b, Q.Z : Q.c]

    guard let lc = (X_a * Y_b), let lcombined = lc * Z_c else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }

    XCTAssertEqual(XYZ_abc.description,lcombined.description,"\(XYZ_abc) ≠ \(lcombined)")

    guard let rc = (Y_b * Z_c), let rcombined = X_a * rc else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }
    
    XCTAssertEqual(XYZ_abc, rcombined,"\(XYZ_abc) ≠ \(rcombined)")
  }
}
