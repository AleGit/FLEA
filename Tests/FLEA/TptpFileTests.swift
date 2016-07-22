import XCTest

@testable import FLEA

public class TptpFileTests : XCTestCase {
  static var allTests : [(String, (TptpFileTests) -> () throws -> Void)] {
    return [
    ("testNonFile", testNonFile),
    ("testPuzFiles", testPuzFiles),
    ("testHwvFiles", testHwvFiles),
    ]
  }

  func check(
    _ name: String,
    _ expected:Int, // expected number of 'inputs'
    _ maxtime:Double = 0,
    _ message:String = "",
    _ file: String = #file,
    _ function : String = #function,
    _ line : Int = #line
  ) {
    let (_, runtime) = mymeasure {
      guard let path = name.p else {
        XCTFail("\(nok):\(line) \(name).p not found.")
        return
      }

      guard let file = Tptp.File(path:path) else {
        XCTFail("\(nok):\(line) \(path) could not be parsed.")
        return
      }

      let ast : Q.Node? = file.ast()

      guard let nodes = ast?.nodes else {
        XCTFail("\(nok):\(line) \(path) is just a single node")
        return
      }

      XCTAssertEqual(nodes.count, expected, "\(nok):\(line)")

      if nodes.count == expected {
        print("\(ok):\(line) \(name).p -> \(path)")
      }
    }

    XCTAssertTrue(runtime.2 < maxtime,"\n\(nok):\(line) \(name) runtime=\(runtime) > \(maxtime)")

    if (runtime.2 < maxtime) {
        print("\(ok):\(line) \(name) read in \(runtime.2)")
    }
  }

  func testNonFile() {
    let name = "PUZ001"
    if let path = name.p {
      XCTFail("(nok) \(name).p \(path)")
    }
  }

  func testPuzFiles() {
    check("PUZ001-1", 12, 0.005)
    check("PUZ001+1", 14, 0.005)
  }

  func testHwvFiles() {
    check("HWV001-1", 42, 0.01)
    // check("HWV134-1", 2332428, 400.0) // debug build is slow
    // check("HWV134+1", 128975, 200.003)
  }

  func testHWV039fof1() {
    check("HWV039+1", 744, 0.1)
  }
}
