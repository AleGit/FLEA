import XCTest

import Foundation
@testable import FLEA

public class YicesTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (YicesTests) -> () throws -> Void)]  {
    return [
      ("testPUZ001c1", testPUZ001c1)
    ]
  }

  typealias Node = FLEA.Tptp.KinIntNode

  func testPUZ001c1() {
    let problem = "PUZ001-1"
    guard let url = URL(fileURLwithProblem:problem) else {
      XCTFail("\(nok) '\(problem)' was not found.")
      return
    }

    guard let file = Tptp.File(url:url) else {
      XCTFail("\(nok) '\(url.relativePath)' could not be parsed.")
      return
    }

    XCTAssertEqual(url.relativePath,file.path,nok)

    /// cnf(name)->input->input->
    ///  |
    /// role -> formula -> [annoations]


    let cnfs = file.cnfs.map { Node(tree:$0.child!.sibling!) }
    XCTAssertEqual(12,cnfs.count,nok)

    print(cnfs.first?.description)
    print("\(cnfs.last!)")

    Yices.setup()
    defer { Yices.teardown() }

    let context = Yices.Context()

    let _ = cnfs.map { context.assert(clause:$0) }

    XCTAssertTrue(context.isSatisfiable)






  }
}