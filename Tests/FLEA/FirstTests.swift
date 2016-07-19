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
    typealias N = FLEA.Tptp.Node
    typealias T = FLEA.Tptp.Symbol

    let X = N(variable:T("X", .Variable))
    let a = N(variable:T("a", .Function))
    let fX = N(symbol:T("f", .Function), nodes:[X])
    let fa = N(symbol:T("f", .Function), nodes:[a])

    let fX_a = fX * [X:a]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)
    XCTAssertEqual(N.allNodes.count,4)

    print(N.allNodes)
  }



}
