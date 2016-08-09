import XCTest

import Foundation

@testable import FLEA

public class URLTests : XCTestCase {
  static var allTests : [(String, (URLTests) -> () throws -> Void)] {
    return [
    ("testFiles",testFiles),

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
      print("var fragment: String?          ", url.fragment ?? "nil")
      // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11
      print("var hashValue: Int             ", url.hashValue)
      print("var host: String?              ", url.host ?? "nil")
      print("var isFileURL: Bool            ", url.isFileURL)
      print("var lastPathComponent: String  ", url.lastPathComponent)
      print("var password: String?          ", url.password ?? "nil")
      print("var path: String               ", url.path)
      print("var pathComponents: [String]   ", url.pathComponents)
      print("var pathExtension: String      ", url.pathExtension)
      print("var port: Int?                 ", url.port)
      print("var query: String?             ", url.query ?? "nil")
      print("var relativePath: String       ", url.relativePath)
      print("var relativeString: String     ", url.relativeString)
      print("var scheme: String?            ", url.scheme ?? "nil")
      print("var user: String?              ", url.user ?? "nil")
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
      print("var absoluteString: String?    ", url.absoluteString ?? "nil")
      print("var absoluteURL: URL?          ", url.absoluteURL)
      print("var baseURL: URL?              ", url.baseURL)
      print("var fragment: String?          ", url.fragment ?? "nil")
      // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11
      print("var hashValue: Int             ", url.hashValue)
      print("var host: String?              ", url.host ?? "nil")
      print("var isFileURL: Bool            ", url.isFileURL)
      print("var lastPathComponent: String  ", url.lastPathComponent)
      print("var password: String?          ", url.password ?? "nil")
      print("var path: String               ", url.path)
      print("var pathComponents: [String]   ", url.pathComponents)
      print("var pathExtension: String      ", url.pathExtension)
      print("var port: Int?                 ", url.port)
      print("var query: String?             ", url.query ?? "nil")
      print("var relativePath: String?      ", url.relativePath ?? "nil")
      print("var relativeString: String     ", url.relativeString)
      print("var scheme: String?            ", url.scheme ?? "nil")
      print("var user: String?              ", url.user ?? "nil")
      print("var standardized: URL          ", url.standardized)
      print("var standardizedFileURL: URL   ", "n/a") // url.standardizedFileURL) // n\a
      //
      print("func checkPromisedItemIsReachable()  ", "n/a") // (try? url.checkPromisedItemIsReachable())) // n\a
      print("func checkResourceIsReachable()      ", "n/a") // (try? url.checkResourceIsReachable())) // n\a
      //
      print("func deletingLastPathComponent()     ",(try? url.deletingLastPathComponent())?.path ?? "nil")
      print("func deletingPathExtension()         ",(try? url.deletingPathExtension())?.path ?? "nil")
      print("func resolvingSymlinksInPath()       ",(try? url.resolvingSymlinksInPath())?.path ?? "nil")

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

    XCTAssertNotNil(URL(fileURLwithProblem:"PUZ001-1"),nok)

    // test local path
    let problem = "Problems/PUZ001-1"
    guard let url = URL(fileURLwithProblem:problem) else {
      XCTFail("\(nok) \(problem) was not resolvable.")
      return
    }
    XCTAssertEqual(problem+".p", url.relativeString)


  }
}
