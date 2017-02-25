import XCTest

@testable import FLEA

public class StringTypedTests: FleaTestCase {

    static var allTests: [(String, (StringTypedTests) -> () throws -> Void)] {
        return [
            ("testPrefixNormalization", testPrefixNormalization),
            ("testPlaceholderNormalization", testPlaceholderNormalization),
        ]
    }

    private final class LocalSmartIntNode: SymbolNameTyped, SymbolTabulating, Sharing, Node,
        ExpressibleByStringLiteral {

        static var symbols = StringIntegerTable<Int>()
        static var pool = WeakSet<N>()

        var symbol: Int = LocalSmartIntNode.symbolize(name: "*", type: .variable)
        var nodes: [N]?

        lazy var hashValue: Int = self.defaultHashValue
        lazy var description: String = self.defaultDescription

        static var X = "X" as N
        static var Y = "Y" as N
        static var a = "a" as N
        static var f1 = "f(f(X,a,X),Y,X)" as N
        static var f2 = "f(f(Y,a,Y),X,Y)" as N
    }

    private typealias N = LocalSmartIntNode

    func testPrefixNormalization() {
        let r1 = N.f1.normalized(prefix: "Z")
        let r2 = N.f2.normalized(prefix: "Z")

        print(r1.description)
        print(r2.debugDescription)

        XCTAssertTrue(r1 === r2, "\(r1)")
        XCTAssertTrue(r1 == r2, "\(r2)")

        XCTAssertEqual("f(f(Z0,a,Z0),Z1,Z0)", r1.description)
        XCTAssertEqual("f(f(Z0,a,Z0),Z1,Z0)", r2.description)
    }

    func testPlaceholderNormalization() {

        let (w0, d0) = N.X.normalized()
        let (w1, d1) = N.f1.normalized()
        let (w2, d2) = N.f2.normalized()

        XCTAssertEqual(1, d0.count)
        XCTAssertEqual(4, d1.count)
        XCTAssertEqual(4, d2.count)

        let x = N.X.symbol
        let y = N.Y.symbol

        XCTAssertEqual([x], d0)

        XCTAssertEqual([x, x, y, x], d1)
        XCTAssertEqual([y, y, x, y], d2)

        XCTAssertEqual(N.X, w0.denormalizing(with: d0))
        XCTAssertEqual(N.f1, w1.denormalizing(with: d1))
        XCTAssertEqual(N.f2, w2.denormalizing(with: d2))

        XCTAssertNil(w0.denormalizing(with: Array(d0.dropFirst())))
        XCTAssertNil(w1.denormalizing(with: Array(d1.dropFirst())))
        XCTAssertNil(w2.denormalizing(with: Array(d2.dropFirst())))

        XCTAssertNil(w1.denormalizing(with: d0))

        XCTAssertEqual(N.X, w0.denormalizing(with: d1))

        XCTAssertEqual(N.Y, w0.denormalizing(with: d2))
        XCTAssertEqual(N.f2, w2.denormalizing(with: d2))
        XCTAssertEqual(N.f1, w2.denormalizing(with: d1))

        /*

         XCTAssertEqual(ε, d0[N.X]!.first!)

         XCTAssertEqual(3, d1[N.X]!.count)
         XCTAssertEqual([0, 0], d1[N.X]![0])
         XCTAssertEqual([0, 2], d1[N.X]![1])
         XCTAssertEqual([2], d1[N.X]![2])

         XCTAssertEqual(3, d2[N.Y]!.count)
         XCTAssertEqual([0, 0], d2[N.Y]![0])
         XCTAssertEqual([0, 2], d2[N.Y]![1])
         XCTAssertEqual([2], d2[N.Y]![2])

         XCTAssertEqual(1, d1[N.Y]!.count)
         XCTAssertEqual([1], d1[N.Y]!.first!)

         XCTAssertEqual(1, d2[N.X]!.count)
         XCTAssertEqual([1], d2[N.X]!.first!)

         print(w0)
         print(w1)
         print(w2)
         */
    }
}
