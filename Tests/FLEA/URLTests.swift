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

    // test canonical path


    if let url = URL(fileURLwithProblem:"PUZ001-1") {
      XCTAssertTrue(url.pathOrEmpty.hasPrefix(homeDirectoryURL.pathOrEmpty))
      XCTAssertTrue(url.pathOrEmpty.hasPrefix(tptpDirectoryURL.pathOrEmpty))
    }
    else {
      XCTFail(nok)
    }

    // test local path
    let problem = "Problems/PUZ001-1"
    if let url = URL(fileURLwithProblem:problem) {
      XCTAssertTrue(url.pathOrEmpty.hasPrefix(homeDirectoryURL.pathOrEmpty))
      XCTAssertFalse(url.pathOrEmpty.hasPrefix(tptpDirectoryURL.pathOrEmpty))
    } else {
      XCTFail("\(nok) \(problem) was not resolvable.")
      return
    }

    if let url = URL(fileURLwithProblem:"PUZ999-1") {
      XCTFail("\(url.path) must not exists")
    }

    let axiomURL = URL(fileURLwithAxiom:"PUZ001-0")
    print(axiomURL)

    let noURL = URL(fileURLwithAxiom:"Axioms/PUZ001-0")
    print(noURL)

    let wrongHint = URL(fileURLwithAxiom:"Axioms/PUZ001-0", problemURL: homeDirectoryURL)
    print(wrongHint)

    let absURL = URL(fileURLwithProblem:"/Users/Shared/TPTP/Problems/PUZ/PUZ001-1")
    print(absURL)


  }
}
