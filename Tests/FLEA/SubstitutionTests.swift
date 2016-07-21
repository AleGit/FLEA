import XCTest

@testable import FLEA

public class SubstitutionTests : XCTestCase {
  static var allTests : [(String, (SubstitutionTests) -> () throws -> Void)] {
    return [
      ("testSubstitutionBasics", testSubstitutionBasics)
    ]
  }

  func testSubstitutionBasics() {
    XCTAssertTrue(true)

    let X_a = [Q.X : Q.a]
    let Y_b = [Q.Y: Q.b]
    let Z_c = [Q.Z : Q.c]
    let XYZ_abc = [Q.X : Q.a, Q.Y: Q.b, Q.Z : Q.c]

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

  func testDictionaryLiteralConvetible() {
    typealias Substitution = FLEA.Instantiator
    let substitution : Substitution = [Q.X : Q.Y]

    XCTAssertEqual(Q.Y, Q.X * substitution)
  }

  func testInstantiator() {
    // print(FLEA.Substitution.dynamicType)
    let X_Y : FLEA.Instantiator = [Q.X : Q.Y]
    let Y_X: FLEA.Instantiator = [Q.Y : Q.X]

    let i1 = X_Y * Y_X
    let i2 = Y_X * X_Y

    print(i1,i2)
  }
}
