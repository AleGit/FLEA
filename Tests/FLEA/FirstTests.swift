import XCTest

@testable import FLEA

public class FirstTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (FirstTests) -> () throws -> Void)]  {
    return [
    ("testOS", testOS),
    ("testFilePath", testTptpRoot)
    ]
  }

  let ok = "✅"
  let nok = "❌"



  /// This test is not put into allTests
  /// - it will execute on OSX
  /// - it will not run on Linux
  func testMacOS() {
    #if os(OSX)
    print("\(ok)  \(#function) executed on macOS.")
    #elseif os(Linux)
    XCTFail("\(nok) \(#function) executed on Linux.")
    #else
    XCTFail("\(nok) \(#function) executed on unsupported OS.")
    #endif
  }

  /// This test should run on every platform.
  func testOS() {
    #if os(OSX)
    print("\(ok)  \(#function) executed on supported macOS.")
    #elseif os(Linux)
    print("\(ok) \(#function) executed on supported Linux.")
    #else
    XCTFail("\(nok) \(#function) executed on unsupported OS.")
    #endif
  }

  func testTptpRoot() {
    guard let tptpRoot = FilePath.tptpRoot else {
      XCTFail("TPTP root path is not available.")
      return
    }

    XCTAssertTrue(tptpRoot.hasSuffix("TPTP"),
    "TPTP root path '\(tptpRoot) does not end with 'TPTP'")
  }

  func testNodeEquality() {
    typealias Node = FLEA.Tptp.Node
    typealias Symbol = FLEA.Tptp.Symbol

    let X = Node(variable:Symbol("X", .Variable))
    let a = Node(variable:Symbol("a", .Function))
    let fX = Node(symbol:Symbol("f", .Function), nodes:[X])
    let fa = Node(symbol:Symbol("f", .Function), nodes:[a])

    let fX_a = fX * [X:Node(variable:Symbol("a", .Function))]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)
    XCTAssertEqual(Node.allNodes.count,4)

    print(Node.allNodes)
  }





}
