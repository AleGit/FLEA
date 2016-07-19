#if os(Linux) || os(FreeBSD)
    import XCTest
    // import Foundation
#else
    import XCTest
    // import SwiftFoundation
#endif

@testable import FLEA

// XCTMain([testCase(MiscFirstTestCase.allTests)])

class FirstTests : XCTestCase {
  #if os(Linux)
  static var allTests = {
    return [
    ("testHelloWorld", testHelloWorld)
    // ("testFilePath", testFilePath)
    // ("testNodeEquality", testNodeEquality)
    // ("testFilePath", testFilePath)
    ]
  }()
  #endif

  func testHelloWorld() {

    let a = "Hello World!"
    let b = "Hello" + " " + "World" + "!"


    print("***",a,b,"***")

    XCTAssertTrue(true,"true is not true")
    XCTAssertFalse(false,"false is not false")

    XCTAssertEqual(a, b,"'\(a)' is not equal to '\(b)'")
  }

  func testNodeEquality() {

      typealias N = FLEA.Tptp.Node
      typealias T = FLEA.Tptp.SymbolType


      // let a = N()
      // print(a)

      // the last two lines compile, but linking fails:

// Compile Swift Module 'MiscTestSuite' (1 sources)
// Linking .build/debug/FLEATests.xctest/Contents/MacOS/FLEATests
// Undefined symbols for architecture x86_64:
//   "__TFCV4FLEA4Tptp4NodeCfT_S1_", referenced from:
//       __TFC13MiscTestSuite10FirstTests16testNodeEqualityfT_T_ in FirstTests.swift.o
//   "__TMaCV4FLEA4Tptp4Node", referenced from:
//       __TFC13MiscTestSuite10FirstTests16testNodeEqualityfT_T_ in FirstTests.swift.o
// ld: symbol(s) not found for architecture x86_64
// <unknown>:0: error: link command failed with exit code 1 (use -v to see invocation)
// <unknown>:0: error: build had 1 command failures
// error: exit(1): /Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-build-tool -f /Users/aXm/Development/FLEA/.build/debug.yaml test



      // let X = N(symbol:T("a",.Variable), nodes:nil) // extension is not visible
      // let xA = [X:a]
      //
      // XCTAssertEqual(X, X * xA,"\(X) != \(X) * \(xA)")




  }

  func testFilePath() {
    // XCTAssertNotNil(FilePath.home)
    // let tptpRoot = FilePath.tptpRoot
    // print (tptpRoot)

  }

}
