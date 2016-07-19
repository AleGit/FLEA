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

  func testSymbolEquality() {
    // let a1 = FLEA.Tptp.Symbol("a", .Function)
    // let a2 = FLEA.Tptp.Symbol("a", .Function)
    // XCTAssertEqual(a1,a2,"\(a1) <> \(a2)")

    // With the three lines above `swift test` emmits:

    // Compile Swift Module 'MiscTestSuite' (1 sources)
    // Linking .build/debug/FLEATests.xctest/Contents/MacOS/FLEATests
    // Undefined symbols for architecture x86_64:
    // "__TFVV4FLEA4Tptp6SymbolCfTSSOS0_10SymbolType_S1_", referenced from:
    //     __TFC13MiscTestSuite10FirstTests18testSymbolEqualityfT_T_ in FirstTests.swift.o
    // "__TMVV4FLEA4Tptp6Symbol", referenced from:
    //     __TFC13MiscTestSuite10FirstTests18testSymbolEqualityfT_T_ in FirstTests.swift.o
    //     __TFFC13MiscTestSuite10FirstTests18testSymbolEqualityFT_T_u1_KT_SS in FirstTests.swift.o
    // "__TWPVV4FLEA4Tptp6Symbols9EquatableS_", referenced from:
    //     __TFC13MiscTestSuite10FirstTests18testSymbolEqualityfT_T_ in FirstTests.swift.o
    // ld: symbol(s) not found for architecture x86_64
    // <unknown>:0: error: link command failed with exit code 1 (use -v to see invocation)
    // <unknown>:0: error: build had 1 command failures
    // error: exit(1): /Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-build-tool -f /Users/aXm/Development/FLEA/.build/debug.yaml test
  }

  func testFilePath() {
    // XCTAssertNotNil(FilePath.home)
    // let tptpRoot = FilePath.tptpRoot
    // print (tptpRoot)

  }

}
