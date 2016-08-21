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
      XCTAssertTrue(url.pathOrEmpty.hasPrefix(homeDirectoryURL.pathOrEmpty))
      XCTAssertTrue(url.pathOrEmpty.hasPrefix(tptpDirectoryURL.pathOrEmpty))
    }
    else {
      XCTFail("\(nok) Problem '\(name)' not found")
    }

    // test local path
    name = "Problems/PUZ001-1"
    if let url = URL(fileURLwithProblem:name) {
      XCTAssertTrue(url.pathOrEmpty.hasPrefix(homeDirectoryURL.pathOrEmpty))
      XCTAssertFalse(url.pathOrEmpty.hasPrefix(tptpDirectoryURL.pathOrEmpty))
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
      XCTAssertTrue(axiomURL.pathOrEmpty.hasSuffix("Axioms/"+name+".ax"))
    } else {
      XCTFail("\(nok) Axiom '\(name)' not found")
    }

    name = "Axioms/PUZ001-0"
    if let noURL = URL(fileURLwithAxiom:name) {
      XCTAssertTrue(noURL.pathOrEmpty.hasSuffix(name+".ax"))
    } else {
      XCTFail("\(nok) Axiom '\(name)' not found")
    }

    name = "Axioms/PUZ001-0"
    if let wrongHint = URL(fileURLwithAxiom:name, problemURL: homeDirectoryURL) {
      XCTAssertTrue(wrongHint.pathOrEmpty.hasSuffix(name+".ax"))
    } else {
      XCTFail("\(nok) Axiom '\(name)' not found")
    }

    name = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1"
    if let absURL = URL(fileURLwithProblem:name) {
      // XCTAssertEqual(name+".p", absURL.pathOrEmpty,"\(nok)")
      print(ok,absURL.pathOrEmpty)
    }

  }


/// Unfortuanatly URL signatures differ (did differ) between Swift 3 Previews on OSX and Linux.
/// This test will highlight future changes.
  func testTypes() {
    let url = URL(fileURLWithPath:"Problems/PUZ001-1.p")

      #if os(OSX)
      XCTAssertTrue(String.self == type(of:url.absoluteString),nok)
      XCTAssertTrue(URL.self == type(of:url.absoluteURL),nok)
      XCTAssertTrue(URL?.self == type(of:url.baseURL),nok)
      XCTAssertTrue(String?.self == type(of:url.fragment),nok)
      XCTAssertTrue(Int.self == type(of:url.hashValue),nok)
      XCTAssertTrue(String?.self == type(of:url.host),nok)
      XCTAssertTrue(Bool.self == type(of:url.isFileURL),nok)
      XCTAssertTrue(String.self == type(of:url.lastPathComponent),nok)
      XCTAssertTrue(String?.self == type(of:url.password),nok)
      XCTAssertTrue(String.self == type(of:url.path),nok)
      XCTAssertTrue([String].self == type(of:url.pathComponents),"\(nok) \(type(of:url.pathComponents))")
      XCTAssertTrue(String.self == type(of:url.pathExtension),nok)
      XCTAssertTrue(Int?.self == type(of:url.port),nok)
      XCTAssertTrue(String?.self == type(of:url.query),nok)
      XCTAssertTrue(String.self == type(of:url.relativePath),nok)
      XCTAssertTrue(String.self == type(of:url.relativeString),nok)
      XCTAssertTrue(String?.self == type(of:url.scheme),nok)
      XCTAssertTrue(String?.self == type(of:url.user),nok)
      // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11

      XCTAssertTrue(URL.self == type(of:url.standardized),nok)
      XCTAssertTrue(URL.self == type(of:url.standardizedFileURL),nok)
      XCTAssertTrue(Bool?.self == type(of:(try? url.checkPromisedItemIsReachable())),nok)
      XCTAssertTrue(Bool?.self == type(of:(try? url.checkResourceIsReachable())),nok)
      XCTAssertTrue(URL.self == type(of:url.deletingLastPathComponent()),nok)
      XCTAssertTrue(URL.self == type(of:url.deletingPathExtension()),nok)
      XCTAssertTrue(URL.self == type(of:url.resolvingSymlinksInPath()),nok)

      #elseif os(Linux)
      XCTAssertTrue(String?.self == type(of:url.absoluteString),nok)
      XCTAssertTrue(URL?.self == type(of:url.absoluteURL),nok)
      XCTAssertTrue(URL?.self == type(of:url.baseURL),nok)
      XCTAssertTrue(String?.self == type(of:url.fragment),nok)
      XCTAssertTrue(Int.self == type(of:url.hashValue),nok)
      XCTAssertTrue(String?.self == type(of:url.host),nok)
      XCTAssertTrue(Bool.self == type(of:url.isFileURL),nok)
      XCTAssertTrue(String?.self == type(of:url.lastPathComponent),nok)
      XCTAssertTrue(String?.self == type(of:url.password),nok)
      XCTAssertTrue(String?.self == type(of:url.path),nok)
      XCTAssertTrue([String]?.self == type(of:url.pathComponents),"\(nok) \(type(of:url.pathComponents))")
      XCTAssertTrue(String?.self == type(of:url.pathExtension),nok)
      XCTAssertTrue(Int?.self == type(of:url.port),nok)
      XCTAssertTrue(String?.self == type(of:url.query),nok)
      XCTAssertTrue(String?.self == type(of:url.relativePath),nok)
      XCTAssertTrue(String.self == type(of:url.relativeString),nok)
      XCTAssertTrue(String?.self == type(of:url.scheme),nok)
      XCTAssertTrue(String?.self == type(of:url.user),nok)

      for (url,message) in [
        (try? url.standardized(),"standardized"),
        (try? url.standardizedFileURL(),"standardizedFileURL"),
        (try? url.deletingLastPathComponent(),"deletingLastPathComponent"),
        (try? url.deletingPathExtension(),"deletingPathExtension"),
        (try? url.resolvingSymlinksInPath(),"resolvingSymlinksInPath")
      ] {
        XCTAssertTrue(URL?.self == type(of:url),"\(nok) url.\(message) -> \(type(of:url))")
      }

      #endif
  }
}
