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
    for url in [
    URL(fileURLWithPath:"Problems/PUZ001-1.p"),
    URL(fileURLWithPath:"~/TPTP/Problems/PUZ001+1.p")
     ] {
    print("url                            ",url)
    print("var absoluteString: String?    ", url.absoluteString ?? "n/a")
    print("var absoluteURL: URL?          ", url.absoluteURL)
    print("var fragment: String?          ",url.fragment ?? "n/a")
    // print("var hasDirectoryPath: Bool ",url.hasDirectoryPath)
    print("var hashValue: Int             ",url.hashValue)
    print("var host: String?              ",url.host ?? "n/a")

    #if os(OSX)
    // print("var isFileReferenceURL: Bool   ",url.isFileReferenceURL)
    #else
    print("var isFileReferenceURL: Bool   ","is not available", #file,#function,#line)
    #endif

    print("var isFileURL: Bool            ",url.isFileURL)
    print("var lastPathComponent: String? ",url.lastPathComponent ?? "n/a")
    // print("var parameterString: String?   ",url.parameterString ?? "n/a")
    print("var password: String?          ",url.password ?? "n/a")
    print("var path: String?              ",url.path ?? "n/a")
    print("var pathComponents: [String]?  ",url.pathComponents ?? [String]())
    print("var pathExtension: String?     ",url.pathExtension ?? "n/a")
    print("var port: Int?                 ",url.port)
    print("var query: String?             ",url.query ?? "n/a")
    print("var relativePath: String?      ",url.relativePath ?? "n/a")
    print("var relativeString: String     ",url.relativeString)
    // print("var resourceSpecifier: String? ",url.resourceSpecifier ?? "n/a")
    print("var scheme: String?            ",url.scheme ?? "n/a")
    print("var user: String?              ",url.user ?? "n/a")

    #if os(OSX)
    print("func checkPromisedItemIsReachable()  ",(try? url.checkPromisedItemIsReachable()) ?? false)
    print("func checkResourceIsReachable()      ",(try? url.checkResourceIsReachable()) ?? false)

        print("func deletingLastPathComponent()     ",url.deletingLastPathComponent())
        print("func deletingPathExtension()         ",url.deletingPathExtension())
        print("func resolvingSymlinksInPath()       ",url.resolvingSymlinksInPath())
    #else
    print("func checkPromisedItemIsReachable()  ","is not available", #file,#function,#line)
    print("func checkResourceIsReachable()      ","is not available", #file,#function,#line)
        print("func deletingLastPathComponent()     ",try? url.deletingLastPathComponent()) // Swift 3 Preview 4
        print("func deletingPathExtension()         ",try? url.deletingPathExtension())
        print("func resolvingSymlinksInPath()       ",try? url.resolvingSymlinksInPath())
    #endif

    #if os(OSX)
    // print("func standardized()                  ",try? url.standardized())
    #else
    print("func standardized()                  ","fatal error: standardized is not yet implemented: file Foundation/NSURL.swift, line 524")
    #endif

    // print("func standardizingPath()             ",try? url.standardizingPath())
    // print(" ",url.host)
    // print(" ",url.host)
    // print(" ",url.host)
    // print(" ",url.host)

}

  }
}
