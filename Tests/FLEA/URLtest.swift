import XCTest

import Foundation

@testable import FLEA

public class URLTests : XCTestCase {
  static var allTests : [(String, (URLTests) -> () throws -> Void)] {
    return [
      ("testFiles",testFiles)
    ]
  }

  func testFiles() {
    guard let home = Process.home else {
      XCTFail("\(nok) home not available)")
      return

    }
    let homeURL = URL(fileURLWithPath:home)

    XCTAssertEqual(home,homeURL.path)


    for url in [
    URL(fileURLWithPath:"Problems/PUZ001-1.p"),
    URL(fileURLWithPath:"~/TPTP/Problems/PUZ001+1.p")
     ] {
       print("")
       #if os(OSX)
    print("url                            ", url)
    print("var absoluteString: String     ", url.absoluteString)
    print("var absoluteURL: URL           ", url.absoluteURL)
    print("var baseURL: URL?              ", url.baseURL ?? "n/a")
    print("var fragment: String?          ", url.fragment ?? "n/a")
    // print("var hasDirectoryPath: Bool     ",url.hasDirectoryPath) // OSX >=10.11
    print("var hashValue: Int             ", url.hashValue)
    print("var host: String?              ", url.host ?? "n/a")
    print("var isFileURL: Bool            ", url.isFileURL)
    print("var lastPathComponent: String  ", url.lastPathComponent)
    print("var password: String?          ", url.password ?? "n/a")
    print("var path: String               ", url.path)
    print("var pathComponents: [String]   ", url.pathComponents)
    print("var pathExtension: String      ", url.pathExtension)
    print("var port: Int?                 ", url.port)
    print("var query: String?             ", url.query ?? "n/a")
    print("var relativePath: String       ", url.relativePath)
    print("var relativeString: String     ", url.relativeString)
    print("var scheme: String?            ", url.scheme ?? "n/a")
    print("var user: String?              ", url.user ?? "n/a")
    print("var standardized: URL          ", url.standardized)
    print("var standardizedFileURL: URL   ", url.standardizedFileURL)
    //
    //
    print("func checkPromisedItemIsReachable()  ",(try? url.checkPromisedItemIsReachable()))
    print("func checkResourceIsReachable()      ",(try? url.checkResourceIsReachable()))
    //
    print("func deletingLastPathComponent()     ",url.deletingLastPathComponent().path)
    print("func deletingPathExtension()         ",url.deletingPathExtension().path)
    print("func resolvingSymlinksInPath()       ",url.resolvingSymlinksInPath().path)



    // print("func standardizingPath()             ",try? url.standardizingPath())
    // print(" ",url.host)
    // print(" ",url.host)
    #elseif os(Linux)
    #endif

}

  }
}
