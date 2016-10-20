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

  private final class N : SymbolStringTyped, Node  {
  typealias S = Tptp.Symbol

  var symbol : S = N.symbolize(string:"*", type:.variable)
  var nodes : [N]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription
}

  private typealias YicesLPO = LPO<N, YicesContext>

  func testAtoB() {
    let yices = YicesContext()
    let a = N(c:"a")
    let b = N(c:"b")

		let lpo = YicesLPO(ctx: yices, trs: [(a, b)])
    let _ = yices.ensure(lpo.gt(a, b))
    XCTAssertTrue(yices.isSatisfiable)

    let m = yices.model
    XCTAssertTrue(m != nil)
		lpo.printEval(m!)
    let a_prec = m!.evalInt(lpo.prec[a.symbol]!)
    let b_prec = m!.evalInt(lpo.prec[b.symbol]!)
    XCTAssertTrue(a_prec != nil && b_prec != nil && a_prec! > b_prec!)
  }

  func testAtoA() {
    let yices = YicesContext()
    let a = N(c:"a")

		let lpo = YicesLPO(ctx: yices, trs: [(a, a)])
    let _ = yices.ensure(lpo.gt(a, a))
    XCTAssertFalse(yices.isSatisfiable)
	}

  func testEmbedding() {
		let x = N(v:"x")
    let f_x = N(f:"f", [x])

    let yices = YicesContext()
		let lpo = YicesLPO(ctx: yices, trs: [(f_x, x)])
    let _ = yices.ensure(lpo.gt(f_x, x))
    XCTAssertTrue(yices.isSatisfiable)
    let _ = yices.ensure(lpo.gt(x, f_x))
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
		let trs = [(b, f_a_a), (f_x_c, b)]
		let lpo = YicesLPO(ctx: yices, trs: trs)
		for (l,r) in trs {
      let _ = yices.ensure(lpo.gt(l, r))
		}
    XCTAssertTrue(yices.isSatisfiable)
		
    let m = yices.model
    XCTAssertTrue(m != nil)
		lpo.printEval(m!)
    let a_p = m!.evalInt(lpo.prec[a.symbol]!)
    let b_p = m!.evalInt(lpo.prec[b.symbol]!)
    let c_p = m!.evalInt(lpo.prec[c.symbol]!)
    let f_p = m!.evalInt(lpo.prec[f_a_a.symbol]!)
    XCTAssertTrue(a_p != nil && b_p != nil && c_p != nil && f_p != nil &&
		              c_p! > b_p! && b_p! > a_p! && b_p! > f_p!)
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
		let lpo = YicesLPO(ctx: yices, trs: [(l, r)])
    let _ = yices.ensure(lpo.gt(r, l))
    XCTAssertFalse(yices.isSatisfiable)
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
		let lpo = YicesLPO(ctx: yices, trs: [(l, r)])
    let _ = yices.ensure(lpo.gt(l, r))
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
    let trs = [(l, r), (i_i_x, x), (i_f_x_y, f_i_y_i_x), (f_0_x, x)]
		let lpo = YicesLPO(ctx: yices, trs: trs)
    for (l, r) in trs {
      let _ = yices.ensure(lpo.gt(r, l))
    }
    XCTAssertFalse(yices.isSatisfiable)
  }

}
