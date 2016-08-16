import XCTest

import Foundation

@testable import FLEA

public class URLTests : XCTestCase {
  static var allTests : [(String, (URLTests) -> () throws -> Void)] {
    return [
    ("testTptpDirectory", testTptp),
    ("testConfigPath", testConfig),
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

    func testConfig() {
      // XCTAssertEqual("Config/xctest.default",FilePath.configPath)
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
      XCTAssertTrue(String?.self == url.absoluteString.dynamicType,nok)
      XCTAssertTrue(URL?.self == url.absoluteURL.dynamicType,nok)
      XCTAssertTrue(URL?.self == url.baseURL.dynamicType,nok)
      XCTAssertTrue(String?.self == url.fragment.dynamicType,nok)
      XCTAssertTrue(Int.self == url.hashValue.dynamicType,nok)
      XCTAssertTrue(String?.self == url.host.dynamicType,nok)
      XCTAssertTrue(Bool.self == url.isFileURL.dynamicType,nok)
      XCTAssertTrue(String?.self == url.lastPathComponent.dynamicType,nok)
      XCTAssertTrue(String?.self == url.password.dynamicType,nok)
      XCTAssertTrue(String?.self == url.path.dynamicType,nok)
      XCTAssertTrue([String]?.self == url.pathComponents.dynamicType,"\(nok) \(url.pathComponents.dynamicType)")
      XCTAssertTrue(String?.self == url.pathExtension.dynamicType,nok)
      XCTAssertTrue(Int?.self == url.port.dynamicType,nok)
      XCTAssertTrue(String?.self == url.query.dynamicType,nok)
      XCTAssertTrue(String?.self == url.relativePath.dynamicType,nok)
      XCTAssertTrue(String?.self == url.relativeString.dynamicType,nok)
      XCTAssertTrue(String?.self == url.scheme.dynamicType,nok)
      XCTAssertTrue(String?.self == url.user.dynamicType,nok)
      // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11
      print("var standardized: URL          ", url.standardized)
      print("var standardizedFileURL: URL   ", url.standardizedFileURL)
      //
      print("func checkPromisedItemIsReachable()  ",(try? url.checkPromisedItemIsReachable()))
      print("func checkResourceIsReachable()      ",(try? url.checkResourceIsReachable()))
      //
      print("func deletingLastPathComponent()     ",url.deletingLastPathComponent().path)
      print("func deletingPathExtension()         ",url.deletingPathExtension().path)
      print("func resolvingSymlinksInPath()       ",url.resolvingSymlinksInPath().path)

      #elseif os(Linux)
      XCTAssertTrue(String?.self == url.absoluteString.dynamicType,nok)
      XCTAssertTrue(URL?.self == url.absoluteURL.dynamicType,nok)
      XCTAssertTrue(URL?.self == url.baseURL.dynamicType,nok)
      XCTAssertTrue(String?.self == url.fragment.dynamicType,nok)
      XCTAssertTrue(Int.self == url.hashValue.dynamicType,nok)
      XCTAssertTrue(String?.self == url.host.dynamicType,nok)
      XCTAssertTrue(Bool.self == url.isFileURL.dynamicType,nok)
      XCTAssertTrue(String?.self == url.lastPathComponent.dynamicType,nok)
      XCTAssertTrue(String?.self == url.password.dynamicType,nok)
      XCTAssertTrue(String?.self == url.path.dynamicType,nok)
      XCTAssertTrue([String]?.self == url.pathComponents.dynamicType,"\(nok) \(url.pathComponents.dynamicType)")
      XCTAssertTrue(String?.self == url.pathExtension.dynamicType,nok)
      XCTAssertTrue(Int?.self == url.port.dynamicType,nok)
      XCTAssertTrue(String?.self == url.query.dynamicType,nok)
      XCTAssertTrue(String?.self == url.relativePath.dynamicType,nok)
      XCTAssertTrue(String.self == url.relativeString.dynamicType,nok)
      XCTAssertTrue(String?.self == url.scheme.dynamicType,nok)
      XCTAssertTrue(String?.self == url.user.dynamicType,nok)
      
      XCTAssertTrue(String?.self == url.path.dynamicType,nok)
      XCTAssertTrue(String?.self == url.path.dynamicType,nok)
      XCTAssertTrue(String?.self == url.path.dynamicType,nok)
      XCTAssertTrue(String?.self == url.path.dynamicType,nok)

      for (url,message) in [
        (try? url.standardized(),"standardized"),
        (try? url.deletingLastPathComponent(),"deletingLastPathComponent"),
        (try? url.deletingPathExtension(),"deletingPathExtension"),
        (try? url.resolvingSymlinksInPath(),"resolvingSymlinksInPath")
      ] {
        XCTAssertTrue(URL?.self == url.dynamicType,"\(nok) url.\(message) -> \(url.dynamicType)")
      }

      #endif
  }
}
