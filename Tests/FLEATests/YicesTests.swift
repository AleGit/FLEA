import XCTest

import Foundation
@testable import FLEA

public class YicesTests: YicesTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (YicesTests) -> () throws -> Void)] {
    return [
      ("testVersionString", testVersionString),
      ("testVersion", testVersion),
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
    Syslog.warning(condition: versionString != expected ) {
      "\n\(nok) actual yices version \(versionString) does not match \(expected)"
    }
    Syslog.info(condition: versionString == expected ) {
      "\n\(ok) actual yices version \(versionString) matches exactly."
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

    let p = "p|~p" as Q.Node

    let context = Yices.Context()
    let _ = context.insure(clause:p)
    XCTAssertTrue(context.isSatisfiable)
  }

  func testBottom() {

    let np = "~p(X)" as Q.Node
    let p = "@cnf p(Y)" as Q.Node


    let context = Yices.Context()
    let _ = context.insure(clause:p)
    let _ = context.insure(clause:np)
    XCTAssertFalse(context.isSatisfiable)

  }

  func testEmptyClause() {
    let symbol = Q.Node.symbolize(string:"|", type:.disjunction)
    let empty = Q.Node(symbol:symbol, nodes: Array<Q.Node>())

    let context = Yices.Context()
    let _ = context.insure(clause:empty)
    XCTAssertFalse(context.isSatisfiable)
  }

  func testVariants() {
    let a = "p(X)|q(Y)" as Q.Node
    let b = "p(Y)|q(Z)" as Q.Node
    let c = "q(Z)|p(X)" as Q.Node
    let d = "q(A)|q(B)|p(C)" as Q.Node

    let ya = Yices.clause(a)
    let yb = Yices.clause(b)
    let yc = Yices.clause(c)
    let yd = Yices.clause(d)

    XCTAssertEqual(ya.0, yb.0)
    XCTAssertEqual(ya.0, yc.0)
    XCTAssertEqual(ya.0, yd.0)
    XCTAssertEqual(yb.0, yc.0)
    XCTAssertEqual(yb.0, yd.0)
    XCTAssertEqual(yc.0, yd.0)


  }
}
