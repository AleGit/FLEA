import XCTest

@testable import FLEA

public class RewriteTests: FleaTestCase {

  static var allTests: [(String, (RewriteTests) -> () throws -> Void)] {
    return [
    ("testTrivial", testTrivial),
    ("testGroup0", testGroup0),
    ("testGroup1", testGroup1),
    ("testGroupCPs", testGroupCPs)
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

  var group_trs : TRS<N> {
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

  func testMatch0() {
		let l = N(v:"X")
    let t = N(c:"a")
		let σ = t.match(l)
    XCTAssertTrue(σ != nil)
    XCTAssertTrue(l.applySubst(σ!).isEqual(to: t))
  }

  func testMatch1() {
		let l = N(f:"f", [N(v:"X"), N(v:"Y")])
		let t = N(f:"f", [N(c:"a"), N(c:"b")])
		let σ = t.match(l)
    XCTAssertTrue(σ != nil)
    XCTAssertTrue(l.applySubst(σ!).isEqual(to: t))
  }

  func testMatch2() {
		let l = N(f:"f", [N(f:"i", [N(v:"x")]), N(v:"Y")])
		let t = N(f:"f", [N(f:"i", [N(f:"i", [N(v:"x")])]), N(v:"Z")])
		let σ = t.match(l)
    XCTAssertTrue(σ != nil)
    XCTAssertTrue(l.applySubst(σ!).isEqual(to: t))
  }

  func testMatch3() {
		let l = N(f:"f", [N(f:"i", [N(v:"X")]), N(v:"X")])
		let t = N(f:"f", [N(f:"i", [N(f:"i", [N(v:"Y")])]), N(v:"Z")])
		let σ = t.match(l)
    XCTAssertTrue(σ == nil)
  }

  func testMatch4() {
		let l = N(f:"f", [N(f:"i", [N(v:"X")]), N(v:"X")])
		let iY = N(f:"i", [N(v:"Y")])
		let t = N(f:"f", [N(f:"i", [iY]), iY])
		let σ = t.match(l)
    XCTAssertTrue(σ != nil)
    XCTAssertTrue(l.applySubst(σ!).isEqual(to: t))
  }

  func testTrivial() {
		let X = N(v:"X")
    XCTAssertTrue(X.nf(with: TRS<N>()).isEqual(to: X))
  }

  func testGroup0() {
		let X = N(v:"X")
		let t = N(f:"i", [N(f:"i", [N(f:"i", [N(f:"i", [X])])])])
		let u = t.nf(with: group_trs)
    XCTAssertTrue(u.isEqual(to: X))
  }

  func testGroup1() {
    let zero = N(c:"0")
    let t = N(f:"i", [zero])
		let rule = R(t, zero)
		let u = t.rewrite_step(with: rule)
		print(u)
    XCTAssertTrue(u != nil && u!.isEqual(to: zero))
  }

  func testGroup2() {
		let x = N(v:"x")
    let y = N(v:"y")
    let f_x_y = N(f:"f", [x, y])
    let i_f_x_y = N(f:"i", [f_x_y])
    let t = N(f:"i", [i_f_x_y])
		let u = t.nf(with: group_trs)
    XCTAssertTrue(u.isEqual(to: f_x_y))
  }

  func testGroupCPs() {
		let cps = group_trs.cps
	  for cp in cps {
      print(cp.lhs, " = ", cp.rhs)
			let s = cp.lhs.nf(with: group_trs)
			let t = cp.rhs.nf(with: group_trs)
      XCTAssertTrue(s.isEqual(to: t))
	  }
	}
}
