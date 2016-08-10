import XCTest

import Foundation

@testable import FLEA

public class URLTests : XCTestCase {
  static var allTests : [(String, (URLTests) -> () throws -> Void)] {
    return [
    ("testFiles", testFiles),
    ("testProblem",testProblem)
    ]
  }

  func testFiles() {
    for url in [
    URL(fileURLWithPath:"Problems/PUZ001-1.p"),
    URL(fileURLWithPath:"~/TPTP/Problems/PUZ001+1.p")
    ] {
      print("")
      #if os(OSX)
      print("url                            ", url)
      print("var absoluteString: String     ", url.absoluteString)
      print("var absoluteURL: URL           ", url.absoluteURL)
      print("var baseURL: URL?              ", url.baseURL)
      print("var fragment: String?          ", url.fragment )
      // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11
      print("var hashValue: Int             ", url.hashValue)
      print("var host: String?              ", url.host )
      print("var isFileURL: Bool            ", url.isFileURL)
      print("var lastPathComponent: String  ", url.lastPathComponent)
      print("var password: String?          ", url.password )
      print("var path: String               ", url.path)
      print("var pathComponents: [String]   ", url.pathComponents)
      print("var pathExtension: String      ", url.pathExtension)
      print("var port: Int?                 ", url.port)
      print("var query: String?             ", url.query )
      print("var relativePath: String       ", url.relativePath)
      print("var relativeString: String     ", url.relativeString)
      print("var scheme: String?            ", url.scheme )
      print("var user: String?              ", url.user )
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
      print("url                            ", url)
      print("var absoluteString: String?    ", url.absoluteString)
      print("var absoluteURL: URL?          ", url.absoluteURL)
      print("var baseURL: URL?              ", url.baseURL)
      print("var fragment: String?          ", url.fragment)
      // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11
      print("var hashValue: Int             ", url.hashValue)
      print("var host: String?              ", url.host)
      print("var isFileURL: Bool            ", url.isFileURL)
      print("var lastPathComponent: String  ", url.lastPathComponent)
      print("var password: String?          ", url.password)
      print("var path: String?              ", url.path)
      print("var pathComponents: [String]   ", url.pathComponents)
      print("var pathExtension: String      ", url.pathExtension)
      print("var port: Int?                 ", url.port)
      print("var query: String?             ", url.query )
      print("var relativePath: String?      ", url.relativePath )
      print("var relativeString: String     ", url.relativeString)
      print("var scheme: String?            ", url.scheme )
      print("var user: String?              ", url.user )
      print("var standardized: URL          ", url.standardized)
      print("var standardizedFileURL: URL   ", "n/a") // url.standardizedFileURL) // n\a
      //
      print("func checkPromisedItemIsReachable()  ", "n/a") // (try? url.checkPromisedItemIsReachable())) // n\a
      print("func checkResourceIsReachable()      ", "n/a") // (try? url.checkResourceIsReachable())) // n\a
      //
      print("func deletingLastPathComponent()     ",(try? url.deletingLastPathComponent())?.path )
      print("func deletingPathExtension()         ",(try? url.deletingPathExtension())?.path )
      print("func resolvingSymlinksInPath()       ",(try? url.resolvingSymlinksInPath())?.path )

      #endif

    }
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
      XCTAssertEqual(name+".p", absURL.pathOrEmpty,"\(nok)")
    }

  }
}
