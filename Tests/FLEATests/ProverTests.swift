import XCTest

@testable import FLEA

/// Test the accumulation of nodes in SmartNode.pool.
/// Nodes MUST NOT accumulate between tests.
public class ProverTests : FleaTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (ProverTests) -> () throws -> Void)]  {
    return [
      ("testPUZ001c1", testPUZ001c1),
    ]
  }

  // local private adoption of protocol to avoid any side affects
  private final class N : SymbolStringTyped, SymbolTabulating, Sharing, Kin, Node, ExpressibleByStringLiteral {
    typealias S = Int
    static var symbols = StringIntegerTable<S>()
    static var pool = WeakSet<N>()
    var folks = WeakSet<N>()
    
    var symbol : S = N.symbolize(string:"*", type:.variable)
    var nodes : [N]? = nil
  }

  func testPUZ001c1() {
      let problem = "PUZ001-1"
      guard let prover = Prover<N>(problem:problem) else {
          XCTFail()
          return
      }

      let (name,_) = prover.problem

      XCTAssertEqual(problem,name)
      XCTAssertEqual(12, prover.clauses.count)
      XCTAssertEqual(0, prover.includes.count)

  
  }
}
