import XCTest

@testable import FLEA

public class MiscPerformanceTests : XCTestCase {
  static var allTests : [(String, (MiscPerformanceTests) -> () throws -> Void)] {
    return [
    ("testSubstitution", testSubstitution),
    ("testXSubstitution", testXSubstitution)
    ]
  }

  func testXSubstitution() {
    measure {
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

  func testSubstitution() {
    Syslog.openLog(ident:"ABC", options:.console,.pid,.perror)
    let _ = Syslog.setLogMask(upTo:.debug)
    measure {
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
      Syslog.debug { "\(X_a) \(Y_b) \(Z_c) \(XYZ_abc)" }
    }
    Syslog.closeLog()
  }
}
