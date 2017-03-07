import XCTest

import Foundation
@testable import FLEA

public class VersionTests: FleaTestCase {

    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (VersionTests) -> () throws -> Void)] {
        return [
            ("testZ3VersionString", testZ3VersionString),
            ("testZ3Version", testZ3Version),

            ("testYicesVersionString", testZ3VersionString),
            ("testYicesVersion", testZ3Version),
        ]
    }

    func testZ3VersionString() {
        let expected = "4.5.1.0"
        let versionString = Z3Basics.versionString
        XCTAssertTrue(versionString.hasPrefix("4."), nok)
        Syslog.warning(condition: versionString != expected) {
            "\(nok) Installed z3 version \(versionString) does not match \(expected) \(nok)"
        }
        Syslog.info(condition: versionString == expected) {
            "\(ok) Installed z3 version \(versionString) matches exactly \(ok)"
        }
    }

    func testZ3Version() {
        XCTAssertEqual(4 as UInt32, Z3Basics.version[0])
    }

    func testYicesVersionString() {
        let expected = "2.5.1"
        let versionString = Yices.versionString
        XCTAssertTrue(versionString.hasPrefix("2."), nok)
        Syslog.warning(condition: versionString != expected) {
            "\(nok) Installed yices version \(versionString) does not match \(expected) \(nok)"
        }
        Syslog.info(condition: versionString == expected) {
            "\(ok) Installed yices version \(versionString) matches exactly. \(ok)"
        }
    }

    func testYicesVersion() {
        XCTAssertEqual(2 as UInt32, Yices.version[0])
    }
}
