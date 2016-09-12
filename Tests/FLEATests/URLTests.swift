import XCTest

import Foundation

@testable import FLEA

public class URLTests : FleaTestCase {
  static var allTests : [(String, (URLTests) -> () throws -> Void)] {
    return [
    ("testTptpDirectory", testTptp),
    ("testProblem",testProblem),
    ("testTypes", testTypes),
    ]
  }


  /// A /path/to/TPTP should be avaiable on every platform
  func testTptp() {
    guard let tptpDirectoryURL = URL.tptpDirectoryURL else {
      XCTFail("TPTP root path is not available.")
      return
    }
    XCTAssertEqual("TPTP", tptpDirectoryURL.lastPathComponent,
    "TPTP root path '\(tptpDirectoryURL) does not end with 'TPTP'")


    print("\(ok) \(#function) \(tptpDirectoryURL.path)")
  }


  func testProblem() {
    guard let homeDirectoryURL = URL.homeDirectoryURL else {
      XCTFail("\(nok) home directory not available!")
      return
    }

    guard let tptpDirectoryURL = URL.tptpDirectoryURL else {
      XCTFail("\(nok) tptp directory not available!")
      return
    }

    XCTAssertFalse(homeDirectoryURL == tptpDirectoryURL,nok)

    var name = "PUZ001-1"
    if let url = URL(fileURLwithProblem:name) {
      XCTAssertTrue(url.path.hasPrefix(homeDirectoryURL.path))
      XCTAssertTrue(url.path.hasPrefix(tptpDirectoryURL.path))
    }
    else {
      XCTFail("\(nok) Problem '\(name)' not found")
    }

    // test local path
    name = "Problems/PUZ001-1"
    if let url = URL(fileURLwithProblem:name) {
      XCTAssertTrue(url.path.hasPrefix(homeDirectoryURL.path))
      XCTAssertFalse(url.path.hasPrefix(tptpDirectoryURL.path))
    } else {
      XCTFail("\(nok) Problem '\(name)' not found")
      return
    }

    name = "PUZ999-1"
    if let url = URL(fileURLwithProblem:name) {
      XCTFail("\(nok) Problem '\(name)' must not exist at \(url.relativeString)")
    }

    name = "PUZ001-0"
    if let axiomURL = URL(fileURLwithAxiom:name) {
      XCTAssertTrue(axiomURL.path.hasSuffix("Axioms/"+name+".ax"))
    } else {
      XCTFail("\(nok) Axiom '\(name)' not found")
    }

    name = "Axioms/PUZ001-0"
    if let noURL = URL(fileURLwithAxiom:name) {
      XCTAssertTrue(noURL.path.hasSuffix(name+".ax"))
    } else {
      XCTFail("\(nok) Axiom '\(name)' not found")
    }

    name = "Axioms/PUZ001-0"
    if let wrongHint = URL(fileURLwithAxiom:name, problemURL: homeDirectoryURL) {
      XCTAssertTrue(wrongHint.path.hasSuffix(name+".ax"))
    } else {
      XCTFail("\(nok) Axiom '\(name)' not found")
    }

    name = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1"
    if let absURL = URL(fileURLwithProblem:name) {
      // XCTAssertEqual(name+".p", absURL.path,"\(nok)")
      print(ok,absURL.path)
    }

  }


/// Unfortuanatly URL signatures differ (did differ) between Swift 3 Previews on OSX and Linux.
/// This test will highlight future changes.
  func testTypes() {
    let url = URL(fileURLWithPath:"Problems/PUZ001-1.p")

    // matching URL property and function signatures on macOS and Linux
      XCTAssertTrue(Int.self == type(of:url.hashValue),nok)
      XCTAssertTrue(URL?.self == type(of:url.baseURL),nok)
      XCTAssertTrue(String?.self == type(of:url.fragment),nok)
      XCTAssertTrue(String?.self == type(of:url.host),nok)
      XCTAssertTrue(Bool.self == type(of:url.isFileURL),nok)
      XCTAssertTrue(String?.self == type(of:url.password),nok)
      XCTAssertTrue(Int?.self == type(of:url.port),nok)
      XCTAssertTrue(String?.self == type(of:url.query),nok)
      XCTAssertTrue(String.self == type(of:url.relativeString),nok)
      XCTAssertTrue(String?.self == type(of:url.scheme),nok)
      XCTAssertTrue(String?.self == type(of:url.user),nok)

      #if os(OSX)
      // (m.a) non-optional on macOS
      XCTAssertTrue(String.self == type(of:url.absoluteString),nok)
      XCTAssertTrue(URL.self == type(of:url.absoluteURL),nok)
      XCTAssertTrue(String.self == type(of:url.lastPathComponent),nok)
      XCTAssertTrue(String.self == type(of:url.path),nok)
      XCTAssertTrue([String].self == type(of:url.pathComponents),"\(nok) \(type(of:url.pathComponents))")
      XCTAssertTrue(String.self == type(of:url.pathExtension),nok)
      XCTAssertTrue(String.self == type(of:url.relativePath),nok)

      if #available(macOS 10.11,*) {
        XCTAssertTrue(Bool.self == type(of:url.hasDirectoryPath),nok) // OSX >=10.11
      }

      // (m.b) non-throwing on macOS
      XCTAssertTrue(URL.self == type(of:url.standardized),nok)
      XCTAssertTrue(URL.self == type(of:url.standardizedFileURL),nok)
      XCTAssertTrue(URL.self == type(of:url.deletingLastPathComponent()),nok)
      XCTAssertTrue(URL.self == type(of:url.deletingPathExtension()),nok)
      XCTAssertTrue(URL.self == type(of:url.resolvingSymlinksInPath()),nok)

      // (m.c) only on macOS
      XCTAssertTrue(Bool?.self == type(of:(try? url.checkPromisedItemIsReachable())),nok)
      XCTAssertTrue(Bool?.self == type(of:(try? url.checkResourceIsReachable())),nok)

      #elseif os(Linux)
      // (l.a) was optional on Linux
      XCTAssertTrue(String.self == type(of:url.absoluteString),nok)
      XCTAssertTrue(URL.self == type(of:url.absoluteURL),nok)
      XCTAssertTrue(String.self == type(of:url.lastPathComponent),nok)
      XCTAssertTrue(String.self == type(of:url.path),nok)
      XCTAssertTrue([String].self == type(of:url.pathComponents),"\(nok) \(type(of:url.pathComponents))")
      XCTAssertTrue(String.self == type(of:url.pathExtension),nok)
      XCTAssertTrue(String.self == type(of:url.relativePath),nok)

      // (l.b) was throwing on Linux
      for (url,message) in [
        (url.standardized,"standardized"),
        // (try? url.standardizedFileURL(),"standardizedFileURL"),
        (url.deletingLastPathComponent(),"deletingLastPathComponent"),
        (url.deletingPathExtension(),"deletingPathExtension"),
        (url.resolvingSymlinksInPath(),"resolvingSymlinksInPath")
      ] {
        XCTAssertTrue(URL.self == type(of:url),"\(nok) url.\(message) -> \(type(of:url))")
      }


      #endif
  }
}
