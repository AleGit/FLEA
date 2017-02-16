import XCTest
import Foundation

@testable import FLEA

public class TptpFileTests: FleaTestCase {
  static var allTests: [(String, (TptpFileTests) -> () throws -> Void)] {
    return [
    ("testNonFile", testNonFile),
    ("testProblems", testProblems)
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
    let (_, runtime) = utileMeasure {
      guard let url = URL(fileURLWithProblem:name) else {
        XCTFail("\(nok):\(line) \(name).p not found.")
        return
      }

      guard let file = Tptp.File(url:url) else {
        XCTFail("\(nok):\(line) \(url.relativePath) could not be parsed.")
        return
      }

      let ast : Q.Node? = file.ast()

      guard let nodes = ast?.nodes else {
        XCTFail("\(nok):\(line) \(url.relativePath) is just a single node")
        return
      }

      XCTAssertEqual(nodes.count, expected, "\(nok):\(name)")

      if nodes.count == expected {
        print("\(ok):\(line) URL(fileURLWithProblem:\(name) -> \(url.relativePath)")
      }
    }

    XCTAssertTrue(runtime.2 < maxtime, "\n\(nok):\(line) \(name) runtime=\(runtime) > \(maxtime)")

    if runtime.2 < maxtime {
        print("\(ok):\(line) \(name) read in \(runtime.2)")
    }
  }

  func testNonFile() {
    let name = "Problems/PUZ001" // local path (does not exist)
    if let url = URL(fileURLWithProblem:name) {
      XCTFail("(nok) URL(fileURLWithProblem:\(name)) \(url.relativePath)")
    }
  }

  func testProblems() {
    for (problem, count, runtime) in [
      ("Problems/PUZ001+1", 14, 0.1),

      ("PUZ001-1", 12, 0.1),
      ("HWV001-1", 42, 0.1),
      ("HWV002-1", 51, 0.1),
      ("HWV003-1", 42, 0.1),
      ("HWV004-1", 36, 0.1),
      ("HWV005-1", 10, 0.1),
      ("HWV006-1", 16, 0.1),
      ("HWV007-1", 14, 0.1),
      // ("HWV008-1", 10, 0.1),
      ("HWV009-1", 3, 0.1),
      ("HWV010-1", 3, 0.1),

      ("HWV011-1", 3, 0.1),
      ("HWV012-1", 4, 0.1),
      ("HWV013-1", 6, 0.1),
      ("HWV014-1", 6, 0.1),
      ("HWV015-1", 6, 0.1),
      ("HWV016-1", 6, 0.1),
      ("HWV017-1", 7, 0.1),
      ("HWV018-1", 6, 0.1),

      ("HWV019-1", 5, 0.1),
      ("HWV020-1", 6, 0.1),

      ("HWV039+1", 744, 0.12)
      // ("HWV067-1",94241,20.0)
    ] {
      check(problem, count, runtime)
    }
  }
}
