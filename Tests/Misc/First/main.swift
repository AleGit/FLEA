#if os(Linux) || os(FreeBSD)
    import XCTest
    // import Foundation
#else
    import XCTest
    // import SwiftFoundation
#endif

@testable import FLEA

// XCTMain([testCase(MiscFirstTestCase.allTests)])

class MiscFirstTestCase : XCTestCase {
  // static var allTests = {
  //   return [
  //   ("testHelloWorld", testHelloWorld)
  //   // ("testFilePath", testFilePath)
  //   // ("testNodeEquality", testNodeEquality)
  //   // ("testFilePath", testFilePath)
  //   ]
  // }()

  func testHelloWorld() {

    let a = "Hello World!"
    let b = "Hello" + " " + "World" + "!"

    XCTAssertTrue(true,"true is not true")
    XCTAssertFalse(false,"false is not false")

    XCTAssertEqual(a, b,"'\(a)' is not equal to '\(b)'")
  }

  func testNodeEquality() {

      typealias N = FLEA.Tptp.Node
      typealias T = FLEA.Tptp.SymbolType


      // let a = N()
      // print(a)

// Compile Swift Module 'FLEA' (25 sources)
// Linking .build/debug/FLEA
// Compile Swift Module 'MiscTestSuite' (1 sources)
// Linking .build/debug/FLEATests.xctest/Contents/MacOS/FLEATests
// Undefined symbols for architecture x86_64:
//   "__TFCV4FLEA4Tptp4NodeCfT_S1_", referenced from:
//       __TFC13MiscTestSuite17MiscFirstTestCase16testNodeEqualityfT_T_ in main.swift.o
//   "__TMaCV4FLEA4Tptp4Node", referenced from:
//       __TFC13MiscTestSuite17MiscFirstTestCase16testNodeEqualityfT_T_ in main.swift.o
// ld: symbol(s) not found for architecture x86_64
// <unknown>:0: error: link command failed with exit code 1 (use -v to see invocation)
// <unknown>:0: error: build had 1 command failures
// error: exit(1): /Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-build-tool -f /Users/aXm/Development/FLEA/.build/debug.yaml test


      // let a = N(symbol:T("a",.Function), nodes:[N]())
      // Tests/Misc/First/main.swift:39:24: error: argument passed to call that takes no arguments
      // let a = N(symbol:T("a",.Function), nodes:[N]())

      // let X = N(symbol:T("a",.Variable), nodes:nil)
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
