#if os(Linux) || os(FreeBSD)
    import XCTest
    // import Foundation
#else
    import XCTest
    import Darwin
    // import SwiftFoundation
#endif

import Foundation

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
    typealias Node = FLEA.Tptp.Node
    typealias Symbol = FLEA.Tptp.Symbol

    let X = Node(variable:Symbol("X", .Variable))
    let a = Node(variable:Symbol("a", .Function))
    let fX = Node(symbol:Symbol("f", .Function), nodes:[X])
    let fa = Node(symbol:Symbol("f", .Function), nodes:[a])

    let fX_a = fX * [X:a]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)
    XCTAssertEqual(Node.allNodes.count,4)

    print(Node.allNodes)
  }

  func testFilePath() {

    let tptpRoot = FilePath.tptpRoot
    XCTAssertNotNil(tptpRoot)

    XCTAssertTrue(tptpRoot?.hasSuffix("TPTP") ?? false)
  }



}
