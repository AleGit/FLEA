import XCTest

@testable import FLEA

public class ProcessTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (ProcessTests) -> () throws -> Void)]  {
    return [
    ("testOS", testOS),
    ("testFilePath", testTptpRoot)
    ]
  }

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
    print("\(ok) \(#function) executed on supported macOS.")
    #elseif os(Linux)
    print("\(ok) \(#function) executed on supported Linux.")
    #else
    XCTFail("\(nok) \(#function) executed on unsupported OS.")
    #endif
  }

  /// A /path/to/TPTP should be avaiable on every platform
  func testTptpRoot() {
    guard let tptpRoot = FilePath.tptpRoot else {
      XCTFail("TPTP root path is not available.")
      return
    }

    XCTAssertTrue(tptpRoot.hasSuffix("TPTP"),
    "TPTP root path '\(tptpRoot) does not end with 'TPTP'")

    print("\(ok) \(#function) \(tptpRoot)")
  }





}
