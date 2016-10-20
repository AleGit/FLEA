import XCTest


import Foundation
@testable import FLEA

public class KBOTests: YicesTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (KBOTests) -> () throws -> Void)] {
    return [
      ("testAtoB", testAtoB),
      ("testAtoA", testAtoA),
      ("testEmbedding", testEmbedding),
      ("testSubterm", testSubterm),
      ("testAssoc1", testAssoc1),
      ("testAssoc2", testAssoc2),
      ("testGroup", testGroup),
      ("testDuplication", testDuplication),
      ("testWeight0", testWeight0),
      ("testAdmissibility", testAdmissibility)
    ]
  }

  private final class N : SymbolStringTyped, Node  {
  typealias S = Tptp.Symbol

  var symbol : S = N.symbolize(string:"*", type:.variable)
  var nodes : [N]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription
}

  private typealias YicesKBO = KBO<N, YicesContext>
  private typealias R = Rule<N>

  func testAtoA() {
    let yices = YicesContext()
    let a = N(c:"a")

		let kbo = YicesKBO(ctx: yices, trs: TRS([R(a, a)]))
    let _ = yices.ensure(kbo.gt(a, a))
    XCTAssertFalse(yices.isSatisfiable)
	}

  func testAtoB() {
    let yices = YicesContext()
    let a = N(c:"a")
    let b = N(c:"b")
    let c = N(c:"c")
    let f_a_c = N(f:"f", [a, c])
    let f_c_b = N(f:"f", [c, b])

    let trs = TRS([R(a, b), R(f_c_b, f_a_c)])
		let kbo = YicesKBO(ctx: yices, trs: trs)
		for rule in trs {
      let _ = yices.ensure(kbo.gt(rule.lhs, rule.rhs))
		}
    XCTAssertTrue(yices.isSatisfiable)

    let m = yices.model
    XCTAssertTrue(m != nil)
		kbo.printEval(m!)
    let a_prec = m!.evalInt(kbo.prec[a.symbol]!)
    let b_prec = m!.evalInt(kbo.prec[b.symbol]!)
    XCTAssertTrue(a_prec != nil && b_prec != nil && a_prec! > b_prec!)
  }

  func testEmbedding() {
		let x = N(v:"x")
    let f_x = N(f:"f", [x])

    let yices = YicesContext()
		let kbo = YicesKBO(ctx: yices, trs: TRS([R(f_x, x)]))
    let _ = yices.ensure(kbo.gt(f_x, x))
    XCTAssertTrue(yices.isSatisfiable)
    let _ = yices.ensure(kbo.gt(x, f_x))
    XCTAssertFalse(yices.isSatisfiable)
  }

  func testSubterm() {
    let a = N(c:"a")
    let b = N(c:"b")
    let c = N(c:"c")
		let x = N(v:"x")
    let f_a_a = N(f:"f", [a, a])
    let f_x_c = N(f:"f", [x, c])

    let yices = YicesContext()
		let trs = TRS([R(b, f_a_a), R(f_x_c, b)])
		let kbo = YicesKBO(ctx: yices, trs: trs)
		for rule in trs {
      let _ = yices.ensure(kbo.gt(rule.lhs, rule.rhs))
		}
    XCTAssertTrue(yices.isSatisfiable)
  }

  func testAssoc1() {
    let x = N(v:"x")
    let y = N(v:"y")
    let z = N(v:"z")
    let f_x_y = N(f:"f", [x, y])
    let f_y_z = N(f:"f", [y, z])
    let l = N(f:"f", [f_x_y, z])
    let r = N(f:"f", [x, f_y_z])
    let yices = YicesContext()
		let kbo = YicesKBO(ctx: yices, trs: TRS([R(l, r)]))
    let _ = yices.ensure(kbo.gt(r, l))
    XCTAssertFalse(yices.isSatisfiable)
  }

  func testDuplication() {
    let x = N(v:"x")
    let y = N(v:"y")
    let s = N(f:"f", [x, x])
    let t = N(f:"g", [y, x])
    for (l,r) in [(s,t), (t,s)] {
      let yices = YicesContext()
		  let kbo = YicesKBO(ctx: yices, trs: TRS([R(l, r)]))
      let _ = yices.ensure(kbo.gt(l, r))
      XCTAssertFalse(yices.isSatisfiable)
    }
  }

  func testAssoc2() {
    let x = N(v:"x")
    let y = N(v:"y")
    let z = N(v:"z")
    let f_x_y = N(f:"f", [x, y])
    let f_y_z = N(f:"f", [y, z])
    let l = N(f:"f", [f_x_y, z])
    let r = N(f:"f", [x, f_y_z])
    let yices = YicesContext()
		let kbo = YicesKBO(ctx: yices, trs: TRS([R(l, r)]))
    let _ = yices.ensure(kbo.gt(l, r))
    XCTAssertTrue(yices.isSatisfiable)
  }

  func testGroup() {
    let x = N(v:"x")
    let y = N(v:"y")
    let z = N(v:"z")
    
    let f_x_y = N(f:"f", [x, y])
    let f_y_z = N(f:"f", [y, z])
    let l = N(f:"f", [f_x_y, z])
    let r = N(f:"f", [x, f_y_z])

    let i_x = N(f:"i", [x])
    let i_i_x = N(f:"i", [i_x])

    let i_y = N(f:"i", [y])
    let f_i_y_i_x = N(f:"f", [i_y, i_x])
    let i_f_x_y = N(f:"i", [f_x_y])

    let zero = N(c:"0")
    let f_0_x = N(f:"f", [zero, x])

    let yices = YicesContext()
    let trs = TRS([R(l, r), R(i_i_x, x), R(i_f_x_y, f_i_y_i_x), R(f_0_x, x)])
		let kbo = YicesKBO(ctx: yices, trs: trs)
    for rule in trs {
      let _ = yices.ensure(kbo.gt(rule.rhs, rule.lhs))
    }
    XCTAssertFalse(yices.isSatisfiable)
  }

  func testWeight0() {
    let x = N(v:"x")
    let y = N(v:"y")
    let i_x = N(f:"i", [x])
    let i_y = N(f:"i", [y])
    let f_x_y = N(f:"f", [x, y])
    let i_f_x_y = N(f:"i", [f_x_y])
    let f_i_y_i_x = N(f:"f", [i_y, i_x])
    let i_i_x = N(f:"i", [i_x])
    let yices = YicesContext()
    let trs = TRS([R(i_f_x_y, f_i_y_i_x), R(i_i_x, x)])
	  let kbo = YicesKBO(ctx: yices, trs: trs)
    for rule in trs {
      let _ = yices.ensure(kbo.gt(rule.lhs, rule.rhs))
    }
    XCTAssertTrue(yices.isSatisfiable)

    let m = yices.model
    XCTAssertTrue(m != nil)
		kbo.printEval(m!)
    let w_i = m!.evalInt(kbo.fun_weight["i"]!)
    XCTAssertTrue(w_i == 0)
    let f_prec = m!.evalInt(kbo.prec[f_x_y.symbol]!)
    let i_prec = m!.evalInt(kbo.prec[i_x.symbol]!)
    XCTAssertTrue(f_prec != nil && i_prec != nil && i_prec! > f_prec!)
  }

  func testAdmissibility() {
    let x = N(v:"x")
    let y = N(v:"y")
    let i_x = N(f:"i", [x])
    let i_y = N(f:"i", [y])
    let f_x_y = N(f:"f", [x, y])
    let i_f_x_y = N(f:"i", [f_x_y])
    let f_i_y_i_x = N(f:"f", [i_y, i_x])
    let h_x = N(f:"h", [x])
    let h_y = N(f:"h", [y])
    let h_f_x_y = N(f:"h", [f_x_y])
    let f_h_y_h_x = N(f:"f", [h_y, h_x])

    let yices = YicesContext()
    let trs = TRS([R(i_f_x_y, f_i_y_i_x), R(h_f_x_y, f_h_y_h_x)])
	  let kbo = YicesKBO(ctx: yices, trs: trs)
    for rule in trs {
      let _ = yices.ensure(kbo.gt(rule.lhs, rule.rhs))
    }
    XCTAssertFalse(yices.isSatisfiable)
  }
}
