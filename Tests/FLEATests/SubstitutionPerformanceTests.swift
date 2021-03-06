import XCTest

@testable import FLEA

public class SubstitutionPerformanceTests: FleaTestCase {
    static var allTests: [(String, (SubstitutionPerformanceTests) -> () throws -> Void)] {
        return [
            ("testDictionarySubstitution", testDictionarySubstitution),
            ("testInstantiatorSubstitution", testInstantiatorSubstitution),
        ]
    }

    public override func setUp() {
        super.setUp()
        // Put setUp code here. This method is called before the invocation of each test method in the class.
        Syslog.openLog(ident: "ABC", options: .console, .pid, .perror)
        _ = Syslog.setLogMask(upTo: .error)
    }

    public override func tearDown() {

        Syslog.closeLog()
        // Put tearDown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInstantiatorSubstitution() {
        measure {
            let X_a: Instantiator = [Q.X: Q.a]
            let Y_b: Instantiator = [Q.Y: Q.b]
            let Z_c: Instantiator = [Q.Z: Q.c]
            let XYZ_abc: Instantiator = [Q.X: Q.a, Q.Y: Q.b, Q.Z: Q.c]

            guard let lc = (X_a * Y_b), let lcombined = lc * Z_c else {
                XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
                return
            }

            XCTAssertEqual(XYZ_abc.description, lcombined.description, "\(XYZ_abc) ≠ \(lcombined)")

            guard let rc = (Y_b * Z_c), let rcombined = X_a * rc else {
                XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
                return
            }

            XCTAssertEqual(XYZ_abc, rcombined, "\(XYZ_abc) ≠ \(rcombined)")
        }
    }

    func testDictionarySubstitution() {
        measure {
            let X_a = [Q.X: Q.a]
            let Y_b = [Q.Y: Q.b]
            let Z_c = [Q.Z: Q.c]
            let XYZ_abc = [Q.X: Q.a, Q.Y: Q.b, Q.Z: Q.c]

            guard let lc = (X_a * Y_b), let lcombined = lc * Z_c else {
                XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
                return
            }

            XCTAssertEqual(XYZ_abc, lcombined, "\(XYZ_abc) ≠ \(lcombined)")

            guard let rc = (Y_b * Z_c), let rcombined = X_a * rc else {
                XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
                return
            }

            XCTAssertEqual(XYZ_abc, rcombined, "\(XYZ_abc) ≠ \(rcombined)")
            // Syslog.debug { "\(X_a) \(Y_b) \(Z_c) \(XYZ_abc)" }
        }
    }
}
