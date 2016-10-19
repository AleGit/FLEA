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
<<<<<<< HEAD
      ("testGroup", testGroup)
=======
      ("testGroup", testGroup),
      ("testDuplication", testDuplication)
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
    ]
  }

  private struct N : Node {
    var symbol : String = ""
    var nodes : [N]? = nil
  }

  private typealias YicesKBO = KBO<N, YicesContext>

  func testAtoA() {
    let yices = YicesContext()
    let a = N(constant:"a")

<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: [(a, a)])
    let _ = yices.ensure(lpo.gt(a, a))
=======
		let kbo = YicesKBO(ctx: yices, trs: [(a, a)])
    let _ = yices.ensure(kbo.gt(a, a))
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
    XCTAssertFalse(yices.isSatisfiable)
	}

  func testAtoB() {
    let yices = YicesContext()
    let a = N(constant:"a")
    let b = N(constant:"b")
    let c = N(constant:"c")
    let f_a_c = N(symbol:"f", nodes:[a, c])
    let f_c_b = N(symbol:"f", nodes:[c, b])

    let trs = [(a, b), (f_c_b, f_a_c)]
<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: trs)
		for (l,r) in trs {
      let _ = yices.ensure(lpo.gt(l, r))
=======
		let kbo = YicesKBO(ctx: yices, trs: trs)
		for (l,r) in trs {
      let _ = yices.ensure(kbo.gt(l, r))
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
		}
    XCTAssertTrue(yices.isSatisfiable)

    let m = yices.model
    XCTAssertTrue(m != nil)
<<<<<<< HEAD
		lpo.printEval(m!)
    let a_prec = m!.evalInt(lpo.prec["a"]!)
    let b_prec = m!.evalInt(lpo.prec["b"]!)
=======
		kbo.printEval(m!)
    let a_prec = m!.evalInt(kbo.prec["a"]!)
    let b_prec = m!.evalInt(kbo.prec["b"]!)
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
    XCTAssertTrue(a_prec != nil && b_prec != nil && a_prec! > b_prec!)
  }

  func testEmbedding() {
		let x = N(variable:"x")
    let f_x = N(symbol:"f", nodes:[x])

    let yices = YicesContext()
<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: [(f_x, x)])
    let _ = yices.ensure(lpo.gt(f_x, x))
    XCTAssertTrue(yices.isSatisfiable)
    let _ = yices.ensure(lpo.gt(x, f_x))
=======
		let kbo = YicesKBO(ctx: yices, trs: [(f_x, x)])
    let _ = yices.ensure(kbo.gt(f_x, x))
    XCTAssertTrue(yices.isSatisfiable)
    let _ = yices.ensure(kbo.gt(x, f_x))
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
    XCTAssertFalse(yices.isSatisfiable)
  }

  func testSubterm() {
    let a = N(constant:"a")
    let b = N(constant:"b")
    let c = N(constant:"c")
		let x = N(variable:"x")
    let f_a_a = N(symbol:"f", nodes:[a, a])
    let f_x_c = N(symbol:"f", nodes:[x, c])

    let yices = YicesContext()
		let trs = [(b, f_a_a), (f_x_c, b)]
<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: trs)
		for (l,r) in trs {
      let _ = yices.ensure(lpo.gt(l, r))
=======
		let kbo = YicesKBO(ctx: yices, trs: trs)
		for (l,r) in trs {
      let _ = yices.ensure(kbo.gt(l, r))
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
		}
    XCTAssertTrue(yices.isSatisfiable)
  }

  func testAssoc1() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let z = N(variable:"z")
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let f_y_z = N(symbol:"f", nodes:[y, z])
    let l = N(symbol:"f", nodes:[f_x_y, z])
    let r = N(symbol:"f", nodes:[x, f_y_z])
    let yices = YicesContext()
<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: [(l, r)])
    let _ = yices.ensure(lpo.gt(r, l))
    XCTAssertFalse(yices.isSatisfiable)
  }

=======
		let kbo = YicesKBO(ctx: yices, trs: [(l, r)])
    let _ = yices.ensure(kbo.gt(r, l))
    XCTAssertFalse(yices.isSatisfiable)
  }

  func testDuplication() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let s = N(symbol:"f", nodes:[x, x])
    let t = N(symbol:"g", nodes:[y, x])
    for (l,r) in [(s,t), (t,s)] {
      let yices = YicesContext()
		  let kbo = YicesKBO(ctx: yices, trs: [(l, r)])
      let _ = yices.ensure(kbo.gt(l, r))
      XCTAssertFalse(yices.isSatisfiable)
    }
  }

>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
  func testAssoc2() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let z = N(variable:"z")
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let f_y_z = N(symbol:"f", nodes:[y, z])
    let l = N(symbol:"f", nodes:[f_x_y, z])
    let r = N(symbol:"f", nodes:[x, f_y_z])
    let yices = YicesContext()
<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: [(l, r)])
    let _ = yices.ensure(lpo.gt(l, r))
=======
		let kbo = YicesKBO(ctx: yices, trs: [(l, r)])
    let _ = yices.ensure(kbo.gt(l, r))
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
    XCTAssertTrue(yices.isSatisfiable)
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

    let yices = YicesContext()
    let trs = [(l, r), (i_i_x, x), (i_f_x_y, f_i_y_i_x), (f_0_x, x)]
<<<<<<< HEAD
		let lpo = YicesKBO(ctx: yices, trs: trs)
    for (l, r) in trs {
      let _ = yices.ensure(lpo.gt(r, l))
=======
		let kbo = YicesKBO(ctx: yices, trs: trs)
    for (l, r) in trs {
      let _ = yices.ensure(kbo.gt(r, l))
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
    }
    XCTAssertFalse(yices.isSatisfiable)
  }

<<<<<<< HEAD
=======
  func testWeight0() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let i_x = N(symbol:"i", nodes:[x])
    let i_y = N(symbol:"i", nodes:[y])
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let i_f_x_y = N(symbol:"i", nodes:[f_x_y])
    let f_i_y_i_x = N(symbol:"f", nodes:[i_y, i_x])
    let i_i_x = N(symbol:"i", nodes:[i_x])
    let yices = YicesContext()
    let trs = [(i_f_x_y, f_i_y_i_x), (i_i_x, x)]
	  let kbo = YicesKBO(ctx: yices, trs: trs)
    for (l,r) in trs {
      let _ = yices.ensure(kbo.gt(l, r))
    }
    XCTAssertTrue(yices.isSatisfiable)

    let m = yices.model
    XCTAssertTrue(m != nil)
		kbo.printEval(m!)
    let w_i = m!.evalInt(kbo.fun_weight["i"]!)
    XCTAssertTrue(w_i == 0)
    let f_prec = m!.evalInt(kbo.prec["f"]!)
    let i_prec = m!.evalInt(kbo.prec["i"]!)
    XCTAssertTrue(f_prec != nil && i_prec != nil && i_prec! > f_prec!)
  }

  func testAdmissibility() {
    let x = N(variable:"x")
    let y = N(variable:"y")
    let i_x = N(symbol:"i", nodes:[x])
    let i_y = N(symbol:"i", nodes:[y])
    let f_x_y = N(symbol:"f", nodes:[x, y])
    let i_f_x_y = N(symbol:"i", nodes:[f_x_y])
    let f_i_y_i_x = N(symbol:"f", nodes:[i_y, i_x])
    let h_x = N(symbol:"h", nodes:[x])
    let h_y = N(symbol:"h", nodes:[y])
    let h_f_x_y = N(symbol:"h", nodes:[f_x_y])
    let f_h_y_h_x = N(symbol:"f", nodes:[h_y, h_x])

    let yices = YicesContext()
    let trs = [(i_f_x_y, f_i_y_i_x), (h_f_x_y, f_h_y_h_x)]
	  let kbo = YicesKBO(ctx: yices, trs: trs)
    for (l,r) in trs {
      let _ = yices.ensure(kbo.gt(l, r))
    }
    XCTAssertFalse(yices.isSatisfiable)
  }
>>>>>>> aef7caee5d2343855b295fb12b8f7ee4b974e7b3
}
