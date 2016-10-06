import XCTest

import Foundation
@testable import FLEA

public class YicesTests: YicesTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (YicesTests) -> () throws -> Void)] {
    return [
      ("testVersionString", testVersionString),
      ("testPUZ001c1", testPUZ001c1),
      ("testTop", testTop),
      ("testBottom", testBottom),
      ("testEmptyClause", testEmptyClause)
    ]
  }

  typealias N = FLEA.Tptp.KinIntNode

  func testVersionString() {
    let expected = "2.5.1"
    let versionString = Yices.versionString
    XCTAssertTrue(versionString.hasPrefix("2."), nok)
    Syslog.debug(condition: { versionString != expected }) {
      "\(nok) actual yices version is \(versionString) is not \(expected)"
    }
  }

    func testVersion() {
      XCTAssertEqual(2 as UInt32, Yices.version[0])
  }

  func testPUZ001c1() {
    let problem = "PUZ001-1"
    guard let url = URL(fileURLWithProblem:problem) else {
      XCTFail("\(nok) '\(problem)' was not found.")
      return
    }

    guard let file = Tptp.File(url:url) else {
      XCTFail("\(nok) '\(url.relativePath)' could not be parsed.")
      return
    }

    XCTAssertEqual(url.relativePath, file.path, nok)

    /// cnf(name)->input->input->
    ///  |
    /// role -> formula -> [annoations]


    let cnfs = file.cnfs.map { N(tree:$0.child!.sibling!) }
    XCTAssertEqual(12, cnfs.count, nok)

    print(cnfs.first?.description)
    print("\(cnfs.last!)")

    let context = Yices.Context()

    let _ = cnfs.map { context.insure(clause:$0) }

    XCTAssertTrue(context.isSatisfiable)
  }

  func testTop() {

    let p = "p|~p" as FLEA.Tptp.SimpleNode

    let context = Yices.Context()
    let _ = context.insure(clause:p)
    XCTAssertTrue(context.isSatisfiable)
  }

  func testBottom() {

    let np = "~p(X)" as FLEA.Tptp.SimpleNode
    let p = "@cnf p(Y)" as FLEA.Tptp.SimpleNode


    let context = Yices.Context()
    let _ = context.insure(clause:p)
    let _ = context.insure(clause:np)
    XCTAssertFalse(context.isSatisfiable)

  }

  func testEmptyClause() {
    let symbol = Tptp.SimpleNode.symbolize(string:"|", type:.disjunction)
    let empty = Tptp.SimpleNode(symbol:symbol, nodes: Array<Tptp.SimpleNode>())

    let context = Yices.Context()
    let _ = context.insure(clause:empty)
    XCTAssertFalse(context.isSatisfiable)
  }
}
