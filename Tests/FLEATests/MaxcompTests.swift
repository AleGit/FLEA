import XCTest

@testable import FLEA

public class MaxcompTests: FleaTestCase {

  static var allTests: [(String, (MaxcompTests) -> () throws -> Void)] {
    return [
    ("testSingleCP", testSingleCP)
    ]
  }

	// local private adoption of protocol to avoid any side affects
	final class N : SymbolStringTyped, Sharing, Node {
		typealias S = Tptp.Symbol
		static var pool = Set<N>()

		var symbol : S = N.symbolize(string:"*", type:.variable)
		var nodes : [N]? = nil
	}
	typealias R = Rule<N>

  func testMaxTerm1() {
		let x = N(v:"x")
    let a = N(c:"a")
    let b = N(c:"b")
    let f_x = N(f:"f", [x])
		let es = TRS<N>([ R(f_x, a), R(f_x, b) ])
    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.maxTerm(es)
    XCTAssertTrue(trs != nil && trs!.count == 2)
  }

  func testSingleCP() {
		let x = N(v:"x")
    let a = N(c:"a")
    let b = N(c:"b")
    let f_x = N(f:"f", [x])
		let es = TRS<N>([ R(f_x, a), R(f_x, b) ])
    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es, max_steps: 3)
    XCTAssertTrue(trs != nil)
    print(trs)
  }

  func testGroup() {
		let x = N(v:"x")
    let y = N(v:"y")
    let z = N(v:"z")
    let zero = N(c:"0")
    
    let f_x_y = N(f:"f", [x, y])
    let f_y_z = N(f:"f", [y, z])
    let l = N(f:"f", [f_x_y, z])
    let r = N(f:"f", [x, f_y_z])
    let i_x = N(f:"i", [x])
    let i_i_x = N(f:"i", [i_x])
    let i_y = N(f:"i", [y])
    let f_i_y_i_x = N(f:"f", [i_y, i_x])
    let i_f_x_y = N(f:"i", [f_x_y])
    let i_0 = N(f:"i", [zero])
    let f_0_x = N(f:"f", [zero, x])
    let f_x_0 = N(f:"f", [x, zero])
    let f_x_i_x = N(f:"f", [x, i_x])
    let f_i_x_x = N(f:"f", [i_x, x])
    let f_i_x_y = N(f:"f", [i_x, y])
    let s1 = N(f:"f", [i_x, f_x_y])
    let s2 = N(f:"f", [x, f_i_x_y])
		let es = TRS<N>([ R(l, r), R(i_i_x, x), R(f_0_x, x), R(f_i_x_x, zero)])
		let res = TRS<N>([ R(l, r), R(i_i_x, x), R(i_f_x_y, f_i_y_i_x), R(f_0_x, x),
		                   R(f_x_0, x), R(i_0, zero), R(f_i_x_x, zero),
							   			R(f_x_i_x, zero), R(s1, y), R(s2, y)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    if (trs != nil) {
      XCTAssertTrue(trs!.count == 10)
      XCTAssertTrue(trs! == res.normalize)
    }
    print(trs)
	}
}
