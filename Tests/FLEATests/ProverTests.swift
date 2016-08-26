import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class ProverTests : FleaTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (ProverTests) -> () throws -> Void)]  {
    return [
      ("testInitPUZ001c1", testInitPUZ001c1),

      ("testInitPUZ062c1", testInitPUZ062c1),
    ]
  }

  // local private adoption of protocol to avoid any side affects
  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node, ExpressibleByStringLiteral {
    typealias S = Int
    static var symbols = StringIntegerTable<S>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()
    
    var symbol : S = N.symbolize(string:Tptp.asterisk, type:.variable)
    var nodes : [N]? = nil
  }


private typealias Prover = ΠρῶτοςProver<N>

  func testInitPUZ001c1() {
      let problem = "PUZ001-1"
      guard let prover = Prover(problem:problem) else {
          XCTFail()
          return
      }

      let (name,_) = prover.problem

      XCTAssertEqual(problem,name)
      XCTAssertEqual(12, prover.clauses.count)
      XCTAssertEqual(0, prover.includes.count)

      XCTAssertTrue(prover.literalsTrie.isEmpty)

      XCTAssertFalse(prover.names.isEmpty)
      XCTAssertEqual(12,prover.names.allValues.count)

      let nc = "prove_neither_charles_nor_butler_did_it"
      print(prover.names.retrieve(from:nc.characters))


      XCTAssertEqual(2,prover.roles.count)
      XCTAssertEqual(11,prover.roles[.hypothesis]?.count)
      XCTAssertEqual(1,prover.roles[.negated_conjecture]?.count)

      XCTAssertEqual(4,prover.sizes.count) // i.e arities up to 3
      XCTAssertEqual(0, prover.sizes[0].count) // no empty clauses
      XCTAssertEqual(5, prover.sizes[1].count) // 5 unit clauses
      XCTAssertEqual(5, prover.sizes[2].count) // 5 clauses with two literals
      XCTAssertEqual(2, prover.sizes[3].count) // 2 clauses with three literals

      XCTAssertEqual(Set([0,1,2,6,7]), prover.sizes[1])
      XCTAssertEqual(Set([3,4,8,9,11]), prover.sizes[2])
      XCTAssertEqual(Set([5,10]), prover.sizes[3])
  }
  
  func testInitPUZ062c1() {
      let problem = "PUZ062-1"
      guard let prover = Prover(problem:problem) else {
          XCTFail()
          return
      }

      let (name,_) = prover.problem

      XCTAssertEqual(problem,name)
      XCTAssertEqual(17, prover.clauses.count)
      XCTAssertEqual(2, prover.includes.count)

      XCTAssertEqual("'Axioms/MSC001-1.ax'", prover.includes.first!.0)
      XCTAssertEqual("'Axioms/MSC001-0.ax'", prover.includes.last!.0)
      XCTAssertEqual(0, prover.includes.first!.1.count)
      XCTAssertEqual(0, prover.includes.last!.1.count)
      XCTAssertTrue(prover.includes.first!.2.isAccessible)
      XCTAssertTrue(prover.includes.last!.2.isAccessible)

      XCTAssertTrue(prover.literalsTrie.isEmpty)

  }
}
