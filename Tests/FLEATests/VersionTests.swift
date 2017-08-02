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
        let name = "z3"
        let expectedPrefix = "4.5"
        let expectedVersion = "4.5.1.0"
        let versionString = Z3Basics.versionString
        XCTAssertTrue(versionString.hasPrefix(expectedPrefix), "\(nok) Installed \(name) '\(versionString)' does not have version prefix '\(expectedPrefix)'")
        Syslog.warning(condition: versionString != expectedVersion) {
            "\(nok) Installed \(name) '\(versionString)' does not match '\(expectedVersion)' \(nok)"
        }
        Syslog.info(condition: versionString == expectedVersion) {
            "\(ok) Installed \(name) '\(versionString)' matches exactly \(ok)"
        }
    }

    func testZ3Version() {
        XCTAssertEqual(4 as UInt32, Z3Basics.version[0])
    }

    func testYicesVersionString() {
        let name = "yices"
        let expectedPrefix = "2.5"

        let expectedVersion = "2.5.2"
        let versionString = Yices.versionString
        XCTAssertTrue(versionString.hasPrefix(expectedPrefix), "\(nok) Installed \(name) '\(versionString)' does not have version prefix '\(expectedPrefix)'")
        Syslog.warning(condition: versionString != expectedVersion) {
            "\(nok) Installed \(name) '\(versionString)' does not match '\(expectedVersion)' \(nok)"
        }
        Syslog.info(condition: versionString == expectedVersion) {
            "\(ok) Installed \(name) '\(versionString)' matches exactly \(ok)"
        }
    }

    func testYicesVersion() {
        XCTAssertEqual(2 as UInt32, Yices.version[0])
    }
}
