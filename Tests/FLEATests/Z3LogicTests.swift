import XCTest
import CZ3Api


import Foundation
@testable import FLEA

public class Z3ContextTests: Z3TestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (Z3ContextTests) -> () throws -> Void)] {
    return [
      ("testVersionString", testVersionString),
      ("testContext", testContext),
      ("testPUZ001c1", testPUZ001c1),
      ("testTop", testTop),
      ("testBot0", testBot0),
      ("testBot1", testBot1),
      ("testBottom", testBottom),
      ("testUnsat0", testUnsat0),
      ("testArith0", testArith0),
      ("testArith1", testArith1),
      ("testArith2", testArith2),
      ("testOpt1", testOpt1),
      ("testEmptyClause", testEmptyClause)
    ]
  }

  typealias N = FLEA.Tptp.KinIntNode

  func testVersionString() {
    XCTAssertEqual("2.4.2", Z3Context.versionString, nok)
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

    let z3 = Z3Context()
    let cnfs = file.cnfs.map { N(tree:$0.child!.sibling!) }
    XCTAssertEqual(12, cnfs.count, nok)

    print(cnfs.first?.description)
    print("\(cnfs.last!)")

    let _ = cnfs.map { z3.ensure(clause: $0) }

    XCTAssertTrue(z3.isSatisfiable)
  }

  func testContext() {
    let _ = Z3Context()
  }


  func testTop() {

    let p = "p|~p" as FLEA.Tptp.SimpleNode

    let z3 = Z3Context()
    let _ = z3.ensure(clause: p)
    XCTAssertTrue(z3.isSatisfiable)
  }

  func testBot0() {
    let z3 = Z3Context()
    let _ = z3.ensure(z3.mkBot)
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testBot1() {

    let p1 = "@cnf p" as FLEA.Tptp.SimpleNode
    let p2 = "@cnf ~p" as FLEA.Tptp.SimpleNode

    let z3 = Z3Context()
    let _ = z3.ensure(clause: p1)
    let _ = z3.ensure(clause: p2)
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testUnsat0() {
    let p1 = "@cnf ~a | b" as FLEA.Tptp.SimpleNode
    let p2 = "@cnf ~b | c" as FLEA.Tptp.SimpleNode
    let p3 = "@cnf ~c | ~a" as FLEA.Tptp.SimpleNode
    let p4 = "@cnf a | ~b" as FLEA.Tptp.SimpleNode
    let p5 = "@cnf b | ~c" as FLEA.Tptp.SimpleNode
    let p6 = "@cnf c | a" as FLEA.Tptp.SimpleNode

    let z3 = Z3Context()
    let _ = z3.ensure(clause: p1)
    let _ = z3.ensure(clause: p2)
    let _ = z3.ensure(clause: p3)
    let _ = z3.ensure(clause: p4)
    let _ = z3.ensure(clause: p5)
    let _ = z3.ensure(clause: p6)
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testBottom() {
    let np = "~p(X)" as FLEA.Tptp.SimpleNode
    let p = "@cnf p(X)" as FLEA.Tptp.SimpleNode

    let z3 = Z3Context()
    let _ = z3.ensure(clause: p)
    let _ = z3.ensure(clause: np)
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testArith0() {
    let z3 = Z3Context()
    let three = z3.mkNum(3)
    let x = z3.mkIntVar("x")
    let y = z3.mkIntVar("y")
    let _ = z3.ensure(x.add(y) == three)
    XCTAssertTrue(z3.isSatisfiable)
  }

  func testArith1() {
    let z3 = Z3Context()
    let three = z3.mkNum(3)
    let two = z3.mkNum(2)
    let four = z3.mkNum(4)
    let x = z3.mkIntVar("x")
    let y = z3.mkIntVar("y")
    let _ = z3.ensure(x.add(y) == four)
    let _ = z3.ensure(x.add(y) ≻ two)
    let _ = z3.ensure(three ≻ x.add(y))
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testArith2() {
    let z3 = Z3Context(optimize: true)
    let three = z3.mkNum(3)
    let two = z3.mkNum(2)
    let four = z3.mkNum(4)
    let x = z3.mkIntVar("x")
    let y = z3.mkIntVar("y")
    let _ = z3.ensure(x.add(y) == four)
    let _ = z3.ensure(x.add(y) ≻ two)
    let _ = z3.ensure(three ≻ x.add(y))
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testOpt1() {
    let z3 = Z3Context(optimize: true)
    let zero = z3.mkNum(0)
    let one = z3.mkNum(1)
    let three = z3.mkNum(3)
    let two = z3.mkNum(2)
    let four = z3.mkNum(4)
    let x = z3.mkIntVar("x")
    let y = z3.mkIntVar("y")
    let sum = (x.add(y) == four).ite(one, zero) +
              (x.add(y) ≻ two).ite(one, zero) +
              (three ≻ x.add(y)).ite(one, zero)
    let _ = z3.maximize(sum)
    XCTAssertTrue(z3.isSatisfiable)
    let max = z3.getMax()
    XCTAssertTrue(max != nil)
    XCTAssertTrue(max! == 2)
  }

  func testEmptyClause() {
    let symbol = Tptp.SimpleNode.symbolize(string:"|", type:.disjunction)
    let empty = Tptp.SimpleNode(symbol:symbol, nodes: Array<Tptp.SimpleNode>())

    let z3 = Z3Context()
    let _ = z3.ensure(clause: empty)
    XCTAssertFalse(z3.isSatisfiable)
  }
}
