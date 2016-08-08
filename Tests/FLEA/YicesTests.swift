import XCTest

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
    guard let path = problem.p else {
      XCTFail("\(nok) '\(problem)' was not found.")
      return
    }

    guard let file = Tptp.File(path:path) else {
      XCTFail("\(nok) '\(path)' could not be parsed.")
      return
    }

    XCTAssertEqual(path,file.path,nok)

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
