import XCTest

@testable import FLEA

public class MaxcompTests: FleaTestCase {

  static var allTests: [(String, (MaxcompTests) -> () throws -> Void)] {
    return [
    ("testMaxTerm", testMaxTerm)
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

  func testMaxTerm() {
		let x = N(v:"x")
    let a = N(c:"a")
    let b = N(c:"b")
    let f_x = N(f:"f", [x])
		let es = TRS<N>([ R(f_x, a), R(f_x, b) ])
    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.maxTerm(es)
    XCTAssertTrue(trs != nil && trs!.count == 2)
  }

  func checkCPJoinability(_ trsopt: TRS<N>?) {
    guard let trs = trsopt else { XCTAssertTrue(false); return }
		let cps = trs.cps
	  for cp in cps {
			let s = cp.lhs.nf(with: trs)
			let t = cp.rhs.nf(with: trs)
      XCTAssertTrue(s.isEqual(to: t))
	  }
  }

  var groupTRS : TRS<N> {
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
		return TRS<N>([ R(l, r), R(i_i_x, x), R(i_f_x_y, f_i_y_i_x), R(f_0_x, x),
                    R(f_x_0, x), R(i_0, zero), R(f_i_x_x, zero),
                    R(f_x_i_x, zero), R(s1, y), R(s2, y)])
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
    let f_0_x = N(f:"f", [zero, x])
    let f_i_x_x = N(f:"f", [i_x, x])
		let es = TRS<N>([ R(l, r), R(f_0_x, x), R(f_i_x_x, zero)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    if (trs != nil) {
      XCTAssertTrue(trs!.count == 10)
      XCTAssertTrue(trs! == groupTRS.normalize)
    }
    print(trs)
    checkCPJoinability(trs)
	}

  /*func testSK3_01() {
		let x = N(v:"x")
    let y = N(v:"y")
    let z = N(v:"z")
    let zero = N(c:"0")

    let f_x_y = N(f:"f", [x, y])
    let f_y_z = N(f:"f", [y, z])
    let l = N(f:"f", [f_x_y, z])
    let r = N(f:"f", [x, f_y_z])
    let i_x = N(f:"i", [x])
    let i_y = N(f:"i", [y])
    let f_0_x = N(f:"f", [zero, x])
    let f_i_x_x = N(f:"f", [i_x, x])
    let f_x_i_y = N(f:"f", [x, i_y])
    let div_x_y = N(f:"div", [x, y])
    let div_rule = R(div_x_y, f_x_i_y)
		let es = TRS<N>([ R(l, r), R(f_0_x, x), R(f_i_x_x, zero), div_rule])
    let res = groupTRS.union(TRS<N>([div_rule]))

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    if (trs != nil) {
      XCTAssertTrue(trs!.count == 11)
      XCTAssertTrue(trs! == res.normalize)
    }
    print(trs)
    checkCPJoinability(trs)
	}*/

  func testAB() {
    let b = N(c:"b")
    let a = N(c:"a")

    let es = TRS<N>([R(a, b), R(b, a)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    XCTAssertTrue(trs!.count == 1)
  }

  func testABCD() {
    let b = N(c:"b")
    let a = N(c:"a")
    let c = N(c:"c")
    let d = N(c:"d")

    let es = TRS<N>([R(a, b), R(c, d)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    XCTAssertTrue(trs!.count == 2)
    checkCPJoinability(trs)
  }

  func testSK3_30() {
		let x = N(v:"x")
    let y = N(v:"y")
    let z = N(v:"z")
    let a = N(c:"a")

    let g_x = N(f:"g", [x])
    let h_y = N(f:"h", [y])
    let f_g_x_x = N(f:"f", [g_x, x])
    let f_g_x_y = N(f:"f", [g_x, y])
    let f_g_x_z = N(f:"f", [g_x, z])
    let f_y_z = N(f:"f", [y, z])
    let l = N(f:"f", [g_x, f_y_z])
    let r = N(f:"k", [f_g_x_y, f_g_x_z])
    let es = TRS<N>([R(f_g_x_x, a), R(f_g_x_y, h_y), R(l, r)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 12)
    XCTAssertTrue(trs != nil)
    checkCPJoinability(trs)
  }

  func testSK3_31() {
		let x = N(v:"x")
		let y = N(v:"y")
    let hx = N(f:"h", [x])
    let hy = N(f:"h", [y])
    let ix = N(f:"i", [x])
    let jx = N(f:"j", [x])
    let jhx = N(f:"j", [hx])
    let fxx = N(f:"f", [x, x])
    let fxhy = N(f:"f", [x, hy])
    let fhxy = N(f:"f", [hx, y])
    let gfxx = N(f:"g", [fxx])
    let es = TRS<N>([R(fxhy, jx), R(fhxy, jhx), R(gfxx, ix)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    checkCPJoinability(trs)
  }

  func testSK3_32() {
		let x = N(v:"x")
		let y = N(v:"y")
    let fxx = N(f:"f", [x, x])
    let gx = N(f:"g", [x])
    let fgxy = N(f:"f", [gx, y])
    let ggx = N(f:"g", [gx])
    let es = TRS<N>([R(fxx, x), R(fgxy, gx), R(ggx, x)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    checkCPJoinability(trs)
  }

  func testSK3_33() {
		let x = N(v:"x")
    let a = N(c:"a")
    let gx = N(f:"g", [x])
    let ga = N(f:"g", [a])
    let fgx = N(f:"f", [gx])
    let ggx = N(f:"g", [gx])
    let es = TRS<N>([R(fgx, gx), R(ga, a), R(ggx, x)])

    let maxcomp = Maxcomp<N, LPO<N, Z3Context>, Z3Context>(es)
    let trs = maxcomp.complete(es.normalize, max_steps: 6)
    XCTAssertTrue(trs != nil)
    checkCPJoinability(trs)
  }
}
