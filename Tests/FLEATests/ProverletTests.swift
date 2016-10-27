import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class ProverletTests: YicesTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (ProverletTests) -> () throws -> Void)] {
    return [
      // ("testInitPUZ001c1", testInitPUZ001c1),
      // ("testInitPUZ062c1", testInitPUZ062c1),
      ("testPUZs", testPUZs),
      ("testClauses", testClauses)
    ]
  }

  // local private adoption of node protocols to avoid any side affects
  private final class TestNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
  ExpressibleByStringLiteral {
    typealias S = Int
    typealias N = TestNode
    static var symbols = StringIntegerTable<S>()
    static var pool = WeakSet<N>()
    // var folks = WeakSet<N>() // protocol Kin

    var symbol: S = N.symbolize(string:Tptp.wildcard, type:.variable)
    var nodes: [N]? = nil

    var description: String { return defaultDescription }
    lazy var hashValue: Int = self.defaultHashValue
  }

  func testPUZs () {
      for (problem, noc, nof, equational) in [
          ("PUZ001-1", 12, 1, false),
          ("PUZ007-1", 28, 2, true),
          ] {
      guard let theProver = FLEA.Proverlet<TestNode>(problem:problem) else {
          XCTFail(nok)
          return
      }

      XCTAssertEqual(noc, theProver.clauseCount, nok)
      XCTAssertEqual(nof, theProver.fileCount, nok)

          }
  }

  func testClauses() {

    let clauses = Clauses<TestNode>()

    XCTAssertTrue((true, 0) == clauses.insert(clause:"p(X)|q(Y)"))    // new
    XCTAssertTrue((false, 0) == clauses.insert(clause:"p(X)|q(Y)"))
    XCTAssertTrue((true, 1) == clauses.insert(clause:"p(X)|q(X)"))    // new

    XCTAssertTrue((true, 2) == clauses.insert(clause:"@cnf p(X)"))    // new

    XCTAssertTrue((false, 2) == clauses.insert(clause:"@cnf p(Z)"))
    XCTAssertTrue((false, 0) == clauses.insert(clause:"p(Z)|q(Y)"))
    XCTAssertTrue((false, 1) == clauses.insert(clause:"p(Z)|q(Z)"))

    XCTAssertTrue((true, 3) == clauses.insert(clause:"q(X)|p(Y)")) // unfortunately new

    XCTAssertEqual(4, clauses.count)

  }

  func testLiterals() {
    print(Yices.clause("p(X)|p(Z)|q(Y)" as TestNode))
    print(Yices.clause("q(X)|p(Y)" as TestNode))
    print(Yices.clause("p(X)|q(Y)" as TestNode))

    print(Yices.clause("~p(X)|p(Z)|q(Y)" as TestNode))
    print(Yices.clause("q(X)|~p(Y)" as TestNode))
    print(Yices.clause("~p(X)|q(Y)" as TestNode))
  }
}
