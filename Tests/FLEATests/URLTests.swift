import XCTest

import Foundation

@testable import FLEA

public class URLTests: FleaTestCase {
    static var allTests: [(String, (URLTests) -> () throws -> Void)] {
        return [
            ("testDirectories", testDirectories),
            ("testPaths", testPaths),
            ("testTypes", testTypes),
            ("testFileManager", testFileManager),
            ("testURL", testURL),
        ]
    }

    func testDirectories() {
        guard let homeDirectoryURL = URL.homeDirectoryURL else {
            XCTFail("\(nok) home directory not available!")
            return
        }

        guard let tptpDirectoryURL = URL.tptpDirectoryURL else {
            XCTFail("\(nok) tptp directory not available!")
            return
        }

        XCTAssertEqual("TPTP", tptpDirectoryURL.lastPathComponent,
                       "TPTP root path '\(tptpDirectoryURL) does not end with 'TPTP'")

        XCTAssertFalse(homeDirectoryURL == tptpDirectoryURL, nok)
    }

    func testPaths() {
        guard let homeDirectoryURL = URL.homeDirectoryURL,
            let tptpDirectoryURL = URL.tptpDirectoryURL else {
            XCTFail("\(nok) home or tptp directory not available!")
            return
        }

        var name = "PUZ001-1"
        if let url = URL(fileURLWithProblem: name) {
            XCTAssertTrue(url.path.hasPrefix(homeDirectoryURL.path))
            XCTAssertTrue(url.path.hasPrefix(tptpDirectoryURL.path))
        } else {
            XCTFail("\(nok) Problem '\(name)' not found")
        }

        name = "Problems/PUZ001-1"
        if let url = URL(fileURLWithProblem: name) {
            XCTAssertTrue(url.path.hasPrefix(homeDirectoryURL.path))
            XCTAssertFalse(url.path.hasPrefix(tptpDirectoryURL.path))
        } else {
            XCTFail("\(nok) Problem '\(name)' not found")
            return
        }

        name = "PUZ999-1"
        if let url = URL(fileURLWithProblem: name) {
            XCTFail("\(nok) Problem '\(name)' must not exist at \(url.relativeString)")
        }

        name = "PUZ001-0"
        if let axiomURL = URL(fileURLWithAxiom: name) {
            XCTAssertTrue(axiomURL.path.hasSuffix("Axioms/" + name + ".ax"))
        } else {
            XCTFail("\(nok) Axiom '\(name)' not found")
        }

        name = "Axioms/PUZ001-0"
        if let noURL = URL(fileURLWithAxiom: name) {
            XCTAssertTrue(noURL.path.hasSuffix("Axioms/PUZ001-0.ax"), "\(nok) \(name) \(noURL.path)")
        } else {
            XCTFail("\(nok) Axiom '\(name)' not found")
        }

        name = "Axioms/PUZ001-0"
        if let wrongHint = URL(fileURLWithAxiom: name, problemURL: homeDirectoryURL) {
            XCTAssertTrue(wrongHint.path.hasSuffix("Axioms/PUZ001-0.ax"),
                          "\(nok) \(name) \(wrongHint.path)")
        } else {
            XCTFail("\(nok) Axiom '\(name)' not found")
        }

        name = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1"
        if let absURL = URL(fileURLWithProblem: name) {
            XCTAssertTrue(absURL.path.hasSuffix("TPTP/Problems/PUZ/PUZ001-1.p"), "\(nok)")
            print(ok, absURL.path)
        }
    }

    /// Unfortuanatly URL signatures differed on Swift 3 Previews on OSX and Linux.
    /// With Swift 3.0 GM Candidate this differences were removed.
    func testTypes() {
        let url = URL(fileURLWithPath: "Problems/PUZ001-1.p")

        XCTAssertTrue(Int.self == type(of: url.hashValue), nok)
        XCTAssertTrue(URL?.self == type(of: url.baseURL), nok)
        XCTAssertTrue(String?.self == type(of: url.fragment), nok)
        XCTAssertTrue(String?.self == type(of: url.host), nok)
        XCTAssertTrue(Bool.self == type(of: url.isFileURL), nok)
        XCTAssertTrue(String?.self == type(of: url.password), nok)
        XCTAssertTrue(Int?.self == type(of: url.port), nok)
        XCTAssertTrue(String?.self == type(of: url.query), nok)
        XCTAssertTrue(String.self == type(of: url.relativeString), nok)
        XCTAssertTrue(String?.self == type(of: url.scheme), nok)
        XCTAssertTrue(String?.self == type(of: url.user), nok)

        // (m.a) non-optional on macOS and linux
        XCTAssertTrue(String.self == type(of: url.absoluteString), nok)
        XCTAssertTrue(URL.self == type(of: url.absoluteURL), nok)
        XCTAssertTrue(String.self == type(of: url.lastPathComponent), nok)
        XCTAssertTrue(String.self == type(of: url.path), nok)
        XCTAssertTrue(
            [String].self == type(of: url.pathComponents),
            "\(nok) \(type(of: url.pathComponents))")
        XCTAssertTrue(String.self == type(of: url.pathExtension), nok)
        XCTAssertTrue(String.self == type(of: url.relativePath), nok)

        if #available(macOS 10.11, *) {
            XCTAssertTrue(Bool.self == type(of: url.hasDirectoryPath), nok) // OSX >=10.11
        }

        // (m.b) non-throwing on macOS and linux
        XCTAssertTrue(URL.self == type(of: url.standardized), nok)
        XCTAssertTrue(URL.self == type(of: url.standardizedFileURL), nok)
        XCTAssertTrue(URL.self == type(of: url.deletingLastPathComponent()), nok)
        XCTAssertTrue(URL.self == type(of: url.deletingPathExtension()), nok)
        XCTAssertTrue(URL.self == type(of: url.resolvingSymlinksInPath()), nok)

        #if os(OSX)

            // (m.c) only on macOS
            XCTAssertTrue(Bool?.self == type(of: (try? url.checkPromisedItemIsReachable())), nok)
            XCTAssertTrue(Bool?.self == type(of: (try? url.checkResourceIsReachable())), nok)

        #elseif os(Linux)

            XCTAssertTrue(Bool.self == type(of: url.hasDirectoryPath), nok)

        #endif
    }

    func testFileManager() {

        guard let url = URL(fileURLWithProblem: "PUZ001-1") else {
            XCTFail("")
            return
        }

        print(url)
    }

    /// Test assumes that tptp directory and config file resides within home directory of process user
    func testURL() {
        guard let home = URL.homeDirectoryURL else {
            XCTFail("Home directory was not found \(nok)")
            return
        }

        let tilde = URL(fileURLWithPath: "~") // "~" is NOT the path to home
        XCTAssertNotEqual(tilde, home, "~ = \(tilde.path) \(nok)")
        XCTAssertTrue(tilde.path.hasPrefix(home.path), "\(home.path) ⋢ \(tilde.path) \(nok)")
        XCTAssertFalse(tilde.isAccessible, "\(tilde.path) is accessible \(nok)")

        if let url = URL.loggingConfigurationURL {
            XCTAssertTrue(url.path.hasPrefix(home.path), "\(home.path) ⋢ \(url.path) \(nok)")
        } else {
            XCTFail("Logging configuration file was not found. \(nok)")
        }

        if let url = URL.tptpDirectoryURL {
            XCTAssertTrue(url.path.hasPrefix(home.path), "\(home.path) ⋢ \(url.path) \(nok)")
        } else {
            XCTFail("Tptp directory was not found. \(nok)")
        }
    }
}
