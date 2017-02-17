import XCTest

import Foundation
@testable import FLEA

public class CommandLineTests: FleaTestCase {
    /// Collect all tests by hand for Linux.
    static var allTests: [(String, (CommandLineTests) -> () throws -> Void)] {
        return [
            // ("testMacOS", testMacOS),
            ("testOS", testOS),
            ("testIfSwift", testIfSwift),
            ("testName", testName),
        ]
    }

    /// This test is not put into allTests
    /// - it will execute on OSX
    /// - it will not run on Linux
    func testMacOSonly() {
        #if os(OSX)
            print("\(ok)  \(#function) executed on macOS.")
        #elseif os(Linux)
            XCTFail("\(nok) \(#function) executed on Linux.")
        #else
            XCTFail("\(nok) \(#function) executed on unsupported OS.")
        #endif
    }

    /// This test should run on every platform.
    func testOS() {
        #if os(OSX)
            print("\(ok) \(#function) executed on supported macOS.")
        #elseif os(Linux)
            print("\(ok) \(#function) executed on supported Linux.")
        #else
            XCTFail("\(nok) \(#function) executed on unsupported OS.")
        #endif
    }

    func testIfSwift() {
        #if swift(>=3.1)
            print(nok, "Swift >= 3.1")
        #elseif swift(>=3.0)
            print(ok, "Swift [3.0,3.1)")
        #elseif swift(>=2.3)
            print(nok, "Swift [2.3,3.0)")
        #elseif swift(>=2.2)
            print(nok, "Swift [2.2,3.3)")
        #else
            print(nok, "Swift < 2.2")
        #endif
    }

    func testName() {
        let name = CommandLine.name
        #if os(OSX)
            XCTAssertEqual("/Applications/Xcode.app/Contents/Developer/usr/bin/xctest",
                           name, "\(nok) \(name)")
        #elseif os(Linux)
            XCTAssertTrue(name.hasSuffix(".build/debug/FLEAPackageTests.xctest"),
                          "\(nok) \(name)")
        #endif
    }
}
