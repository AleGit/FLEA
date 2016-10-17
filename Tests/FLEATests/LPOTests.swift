import XCTest


import Foundation
@testable import FLEA

public class LPOTests: YicesTestCase {

  /// Collect all tests by hand for Linux.
  static var allTests: [(String, (LPOTests) -> () throws -> Void)] {
    return [
      ("testAtoB", testAtoB),
      ("testAtoA", testAtoA),
      ("testEmbedding", testEmbedding),
      ("testSubterm", testSubterm),
      ("testAssoc1", testAssoc1),
      ("testAssoc2", testAssoc2),
      ("testGroup", testGroup)
    ]
  }

  private struct N : Node {
    var symbol : String = ""
    var nodes : [N]? = nil
  }

  private typealias Z3LPO = LPO<N, YicesContext>

  func testAtoB() {
    let z3 = YicesContext()
    let a = N(constant:"a")
    let b = N(constant:"b")

		let lpo = Z3LPO(ctx: z3, trs: [(a, b)])
    let _ = z3.ensure(lpo.gt(a, b))
    XCTAssertTrue(z3.isSatisfiable)

    let m = z3.model
    XCTAssertTrue(m != nil)
		lpo.printEval(m!)
    let a_prec = m!.evalInt(lpo.prec["a"]!)
    let b_prec = m!.evalInt(lpo.prec["b"]!)
    XCTAssertTrue(a_prec != nil && b_prec != nil && a_prec! > b_prec!)
  }

  func testAtoA() {
    let z3 = YicesContext()
    let a = N(constant:"a")

		let lpo = Z3LPO(ctx: z3, trs: [(a, a)])
    let _ = z3.ensure(lpo.gt(a, a))
    XCTAssertFalse(z3.isSatisfiable)
	}

  func testEmbedding() {
		let x = N(variable:"x")
    let f_x = N(symbol:"f", nodes:[x])

    let z3 = YicesContext()
		let lpo = Z3LPO(ctx: z3, trs: [(f_x, x)])
    let _ = z3.ensure(lpo.gt(f_x, x))
    XCTAssertTrue(z3.isSatisfiable)
    let _ = z3.ensure(lpo.gt(x, f_x))
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testSubterm() {
    let a = N(constant:"a")
    let b = N(constant:"b")
    let c = N(constant:"c")
		let x = N(variable:"x")
    let f_a_a = N(symbol:"f", nodes:[a, a])
    let f_x_c = N(symbol:"f", nodes:[x, c])

    let z3 = YicesContext()
		let trs = [(b, f_a_a), (f_x_c, b)]
		let lpo = Z3LPO(ctx: z3, trs: trs)
		for (l,r) in trs {
      let _ = z3.ensure(lpo.gt(l, r))
		}
    XCTAssertTrue(z3.isSatisfiable)
		
    let m = z3.model
    XCTAssertTrue(m != nil)
		lpo.printEval(m!)
    let a_p = m!.evalInt(lpo.prec["a"]!)
    let b_p = m!.evalInt(lpo.prec["b"]!)
    let c_p = m!.evalInt(lpo.prec["c"]!)
    let f_p = m!.evalInt(lpo.prec["f"]!)
    XCTAssertTrue(a_p != nil && b_p != nil && c_p != nil && f_p != nil &&
		              c_p! > b_p! && b_p! > a_p! && b_p! > f_p!)
  }

  func testAssoc1() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let z = N(variable:"z")
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let f_y_z = N(symbol:"f", nodes:[y, z])
    let l = N(symbol:"f", nodes:[f_x_y, z])
    let r = N(symbol:"f", nodes:[x, f_y_z])
    let z3 = YicesContext()
		let lpo = Z3LPO(ctx: z3, trs: [(l, r)])
    let _ = z3.ensure(lpo.gt(r, l))
    XCTAssertFalse(z3.isSatisfiable)
  }

  func testAssoc2() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let z = N(variable:"z")
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let f_y_z = N(symbol:"f", nodes:[y, z])
    let l = N(symbol:"f", nodes:[f_x_y, z])
    let r = N(symbol:"f", nodes:[x, f_y_z])
    let z3 = YicesContext()
		let lpo = Z3LPO(ctx: z3, trs: [(l, r)])
    let _ = z3.ensure(lpo.gt(l, r))
    XCTAssertTrue(z3.isSatisfiable)
  }

  func testGroup() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let z = N(variable:"z")
    
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let f_y_z = N(symbol:"f", nodes:[y, z])
    let l = N(symbol:"f", nodes:[f_x_y, z])
    let r = N(symbol:"f", nodes:[x, f_y_z])

    let i_x = N(symbol:"i", nodes:[x])
    let i_i_x = N(symbol:"i", nodes:[i_x])

    let i_y = N(symbol:"i", nodes:[y])
    let f_i_y_i_x = N(symbol:"f", nodes:[i_y, i_x])
    let i_f_x_y = N(symbol:"i", nodes:[f_x_y])

    let zero = N(constant:"0")
    let f_0_x = N(symbol:"f", nodes:[zero, x])

    let z3 = YicesContext()
    let trs = [(l, r), (i_i_x, x), (i_f_x_y, f_i_y_i_x), (f_0_x, x)]
		let lpo = Z3LPO(ctx: z3, trs: trs)
    for (l, r) in trs {
      let _ = z3.ensure(lpo.gt(r, l))
    }
    XCTAssertFalse(z3.isSatisfiable)
  }

}
