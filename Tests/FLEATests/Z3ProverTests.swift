import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class Z3ProverTests: Z3TestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (Z3ProverTests) -> () throws -> Void)] {
    return [
      // ("testInitPUZ001c1", testInitPUZ001c1),
      // ("testInitPUZ062c1", testInitPUZ062c1),
      ("testPUZs", testPUZs)
    ]
  }

  // local private adoption of protocol to avoid any side affects
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


private typealias Prover = ProverY<TestNode, Z3Context>




  func testPUZs () {
      for (problem, noc, nof, equational) in [
          ("PUZ001-1", 12, 1, false),
          // ("PUZ007-1", 28, 2, true) // slow
          ] {
      guard let theProver = Prover(problem:problem) else {
          XCTFail(nok)
          return
      }

      XCTAssertEqual(noc, theProver.clauseCount, nok)
      XCTAssertEqual(nof, theProver.fileCount, nok)
      XCTAssertEqual(equational, theProver.isEquational, "\(nok) \(problem)")

      let (result, runtime) = utileMeasure {
        theProver.run(timeout: 100.0)
      }
      XCTAssertEqual(true, result, "\(nok) \(problem)")
      print("problem:", problem, result, runtime,
            "clauses:", theProver.clauseCount,
            "ensured:", theProver.insuredClausesCount)
      }

  }
}
