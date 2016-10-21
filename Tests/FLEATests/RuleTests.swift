import XCTest

@testable import FLEA

public class RuleTests: FleaTestCase {

  static var allTests: [(String, (RuleTests) -> () throws -> Void)] {
    return [
    ("testRenaming", testRenaming),
    ("testTrivialCP", testTrivialCP),
    ("testCP0", testCP0),
    ("testCP1", testCP1),
    ("testCP2", testCP2)
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


  func testRenaming() {
		let X = N(v:"X")
		let Y = N(v:"Y")
		let a = N(c:"a")
		let fXY = N(f:"f", [X, Y])
		let ffXYa = N(f:"f", [fXY, a])
		let fffXYafXY = N(f:"f", [ffXYa, fXY])
		let (s, t) = R(fXY, fffXYafXY).rename.terms
		print(s.defaultDescription, t.defaultDescription)
    XCTAssertTrue((t =?= fffXYafXY) != nil)
  }

  func testTrivialCP() {
		let X = N(v:"X")
		let b = N(c:"b")
		let gb = N(f:"g", [b])
		let fbX = N(f:"f", [b, X])
		let rl = R(fbX, gb)
		let cp = rl.cp(inner: rl, at:ε)
    XCTAssertTrue(cp == nil)
  }

  func testCP0() {
		let X = N(v:"X")
		let Y = N(v:"Y")
		let a = N(c:"a")
		let b = N(c:"b")
		let gX = N(f:"g", [X])
		let gb = N(f:"g", [b])
		let fXY = N(f:"f", [X, Y])
		let fbX = N(f:"f", [b, X])
		let rl1 = R(fbX, a)
		let rl2 = R(fXY, gX)
		let cp = rl2.cp(inner: rl1, at:ε)
    XCTAssertTrue(cp != nil)
		XCTAssertTrue(cp!.lhs.isEqual(to: a) && cp!.rhs.isEqual(to: gb))
  }

  func testCP1() {
		let X = N(v:"X")
		let b = N(c:"b")
		let c = N(c:"c")
		let gb = N(f:"g", [b])
		let fbX = N(f:"f", [b, X])
		let fcX = N(f:"f", [c, X])
		let rl1 = R(fbX, gb)
		let rl2 = R(b, c)

		let cp1 = rl1.cp(inner: rl2, at:[0])
    XCTAssertTrue(cp1 != nil)
		XCTAssertTrue(cp1!.lhs.isEqual(to: fcX) && cp1!.rhs.isEqual(to: gb))

		let cp2 = rl1.cp(inner: rl2, at:[1])
    XCTAssertTrue(cp2 == nil)
  }

  func testCP2() {
		let X = N(v:"X")
		let Y = N(v:"Y")
		let gX = N(f:"g", [X])
		let gY = N(f:"g", [Y])
		let hX = N(f:"h", [X])
		let hgX = N(f:"h", [gX])
		let ggY = N(f:"g", [gY])
		let fXgX = N(f:"f", [X, gX])
		let fgXX = N(f:"f", [gX, X])
		let rl1 = R(fgXX, hX)
		let rl2 = R(ggY, Y)

		let cp = rl1.cp(inner: rl2, at:[0])
		print(cp)
    XCTAssertTrue(cp != nil)
		XCTAssertTrue(cp!.lhs.isEqual(to: fXgX) && cp!.rhs.isEqual(to: hgX))
  }
}
