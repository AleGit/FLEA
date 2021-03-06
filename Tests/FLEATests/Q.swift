#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif
import Foundation
import XCTest
@testable import FLEA

let ok = "✅ "
let nok = "❌ "

public class FleaTestCase: XCTestCase {

    /// set up logging once _before_ all tests of a test class
    public override class func setUp() {
        super.setUp()
        Syslog.openLog(options: .console, .pid, .perror)
        let logLevel = Syslog.maximalLogLevel

        _ = Syslog.setLogMask(upTo: logLevel)
        // print("+++ FleaTestCase.\(#function) +++")
        Syslog.carping = false // off by default
    }

    /// teardown logging once _after_ all tests of a test class
    public override class func tearDown() {
        // print("=== FleaTestCase.\(#function) ===")
        Syslog.closeLog()
        super.tearDown()
    }
}

public class YicesTestCase: FleaTestCase {
    /// set up yices globals _before_ each test function
    public override func setUp() {
        super.setUp()
        Yices.setUp()
        print("+++ YicesTestCase.\(#function) +++")
    }

    /// tear down yices globals _after_ each test function
    public override func tearDown() {
        print("+++ YicesTestCase.\(#function) +++")
        Yices.tearDown()
        super.tearDown()
    }
}

struct Q {
    static let wildcard = "*"

    typealias S = Tptp.Symbol

    final class SimpleNode: SymbolNameTyped, FLEA.Node,
        ExpressibleByStringLiteral {
        typealias N = SimpleNode

        var symbol = S(wildcard, .variable)
        var nodes: [N]?
    }

    final class SharingNode: SymbolNameTyped, Sharing, FLEA.Node,
        ExpressibleByStringLiteral {
        typealias N = SharingNode

        static var pool = Set<N>()

        var symbol = S(wildcard, .variable)
        var nodes: [N]?

        lazy var hashValue: Int = self.defaultHashValue
    }

    final class SmartNode: SymbolNameTyped, Sharing, FLEA.Node,
        ExpressibleByStringLiteral {
        typealias N = SmartNode

        static var pool = WeakSet<N>()

        var symbol = S(wildcard, .variable)
        var nodes: [N]?

        lazy var hashValue: Int = self.defaultHashValue
        var description: String { return defaultDescription }
    }

    final class KinNode: SymbolNameTyped, Sharing, Kin, FLEA.Node, ExpressibleByStringLiteral {
        typealias N = KinNode

        static var pool = WeakSet<N>()
        var folks = WeakSet<N>()

        var symbol = S(wildcard, .variable)
        var nodes: [N]?

        lazy var hashValue: Int = self.defaultHashValue
    }

    typealias Node = Q.SmartNode

    static var X = Q.Node(v: "X")
    static var Y = Q.Node(v: "Y")
    static var Z = Q.Node(v: "Z")
    static var a = Q.Node(c: "a")
    static var b = Q.Node(c: "b")
    static var c = Q.Node(c: "c")

    static var fXY = "f(X,Y)" as Q.Node
    static var fXZ = fXY * [Y: Z]
    static var fYZ = fXZ * [X: Y]
    static var fXX = fXY * X

    static var gXYZ = "g(X,Y,Z)" as Q.Node
    static var hX = "h(X)" as Q.Node

    static var X_a = [X: a]
    static var Y_b = [Y: b]
    static var Z_c = [Z: c]

    static var fab = fXY * [X: a, Y: b]
    static var faa = fXY * [X: a, Y: a]
    static var gabc = gXYZ * [X: a, Y: b, Z: c]
    static var ha = hX * [X: a]

    static var ffaaZ = "f(f(a,a),Z)" as Q.Node
}

extension Q {
    static func parse<N: FLEA.Node>(problem: String) -> [N]
        where N: SymbolNameTyped {
        print("N:Node == \(String(reflecting: N.self))")

        guard let url = URL(fileURLWithProblem: problem) else {
            print("Path for '\(problem)' could not be found.")
            return [N]()
        }

        let (parseResult, parseTime) = utileMeasure {
            FLEA.Tptp.File(url: url)
        }
        guard let tptpFile = parseResult else {
            print("\(url.relativePath) could not be parsed (is not a valid tptp file).")
            return [N]()
        }
        print("parse time: \(parseTime) '\(url.relativePath)'")

        let (countResult, countTime) = utileMeasure {
            tptpFile.inputs.reduce(0) { a, _ in a + 1 }
        }

        print("count=\(countResult), time=\(countTime) '\(url.relativePath)'")

        let (result, time) = utileMeasure {
            // tptpFile.inputs.map { N(tree:$0) }
            tptpFile.ast() as N?
        }

        guard let inputs = result?.nodes else {
            print("\(url.relativePath) did not convert to \(N.self)")
            return [N]()
        }

        print("init=\(result!.nodes!.count), time=\(time) '\(url.relativePath)'")

        print(problem, "count :", inputs.count)

        guard inputs.count > 0 else { return [N]() }

        print("#1", inputs[0])

        print("Node == \(String(reflecting: N.self))")
        return inputs
    }
}
