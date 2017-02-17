/// Demo
public struct Demo {
    static let hwvProblem = "HWV134-1"
    static let cnfProblem = "PUZ001-1"
    static let fofProblem = "PUZ001+1"

    static let line = Array(repeating: "=", count: 80).joined(separator: "")

    static var show: Bool = true

    static let demos = [
        "cnf": (Demo.Problem.parseCnf, "Parse \(cnfProblem) (cnf)"),
        "fof": (Demo.Problem.parseFof, "Parse \(fofProblem) (fof)"),
        "simple": (Demo.Problem.simpleNode, "Parse \(hwvProblem) with simple node(expensive)"),
        "sharing": (Demo.Problem.sharingNode, "Parse \(hwvProblem) with sharing node (expensive)"),
        "smart": (Demo.Problem.smartNode, "Parse \(hwvProblem) with smart node (expensive)"),
        "Kin": (Demo.Problem.kinNode, "Parse \(hwvProblem) with kin node (expensive)"),
        "broken": (Demo.Problem.broken, "Parse invalid file"),
        "pool": (Demo.sharing, "Node sharing"),
        "mgu": (Demo.Unification.demo, "Unfication"),
        "succ": (Demo.Prover.succ, "Successor"),
    ]

    public static func demo() -> Int? {
        guard let names = CommandLine.options["--demo"] else {
            return nil
        }

        guard names.count > 0 else {
            print(line)
            print("You've selected '--demo' with no list of demos.")
            for (key, value) in demos {
                print("   '\(key)' \tdescription:'\(value.1)")
            }
            let prefix = "  $ \(CommandLine.arguments[0]) --demo"
            print("To execute all demos type the following line:")
            let args = demos.map { $0 }.reduce(prefix) { $0 + " \($1.0)" }
            print(args)
            return 0
        }

        for n in names {
            print(line)
            guard let f = demos[n]?.0 else {
                print("DEMO '\(n)' does not exist.")
                continue
            }
            print("utileMeasure DEMO '\(n)'")
            let (_, runtime) = utileMeasure(f: f)
            print("RUNTIME OF DEMO '\(n)'", runtime)
        }
        print(line)
        return names.count
    }
}

/// MARK: - Unification

extension Demo {
    struct Unification {
        static func demo() -> Int {

            // let nodes : [Demo.KinNode] = demoCreateNodes()

            let X = Demo.KinNode(v: "X")
            let Y = Demo.KinNode(v: "Y")
            let Z = Demo.KinNode(v: "Z")

            let a = Demo.KinNode(c: "a")
            let b = Demo.KinNode(c: "a")

            let fXY = Demo.KinNode(f: "f", [X, Y])

            let fYX = fXY * [X: Y, Y: X]
            let fYZ = fXY * [X: Y, Y: Z]
            let fab = fXY * [X: a, Y: b]
            let ffabZ = fXY * [X: fab, Y: Z]

            let nodes = [fXY, fYX, fYZ, fab, ffabZ]

            for f in nodes {
                for g in nodes {
                    guard let mgu = f =?= g else {
                        print("\(f) =?= \(g) is not unifiable.")
                        continue
                    }
                    print("\(f) =?= \(g) = \(mgu)")
                }
            }
            return nodes.count
        }
    }
}

/// MARK: - Node

extension Demo {

    final class SimpleNode: SymbolStringTyped, Node,
        ExpressibleByStringLiteral {
        typealias N = SimpleNode

        var symbol = Tptp.Symbol("*", .variable)
        var nodes: [N]?
    }

    final class SharingNode: SymbolStringTyped, Sharing, Node {
        static var counter = 0

        static var pool = Set<Demo.SharingNode>()

        var symbol = Tptp.Symbol("", .undefined)
        var nodes: [Demo.SharingNode]?
        // swiftlint:disable variable_name
        var c: Int = {
            let a = SharingNode.counter
            SharingNode.counter += 1
            return a
        }()

        // swiftlint:enable variable_name

        init() {
            print("\(#function)#\(self.c)")
        }

        lazy var hashValue: Int = self.defaultHashValue
        lazy var description: String = self.debugDescription

        var debugDescription: String {
            guard let nodes = self.nodes?.map({ $0.description }), nodes.count > 0
            else {
                return "\(self.symbol)'\(self.c)"
            }
            let tuple = nodes.map { $0 }.joined(separator: ",")
            return "\(self.symbol)'\(self.c)(\(tuple))"
        }

        deinit {
            print("\(#function)#\(self.c): \(self)")
        }
    }

    final class SmartNode: SymbolStringTyped, Sharing, Node,
        ExpressibleByStringLiteral {
        typealias N = Demo.SmartNode

        static var pool = WeakSet<N>()

        var symbol = Tptp.Symbol("*", .variable)
        var nodes: [N]?

        lazy var hashValue: Int = self.defaultHashValue
        var description: String { return self.defaultDescription }
    }

    final class KinNode: SymbolStringTyped, Sharing, Kin, Node, ExpressibleByStringLiteral {
        typealias N = Demo.KinNode

        static var pool = WeakSet<N>()
        var folks = WeakSet<N>()

        var symbol = Tptp.Symbol("*", .variable)
        var nodes: [N]?

        lazy var hashValue: Int = self.defaultHashValue
    }
}

extension Demo {
    static func sharing() -> Int {
        typealias N = Demo.SharingNode
        typealias S = Tptp.Symbol

        func fxy() -> N {
            let X = N(variable: S("X", .variable))
            let Y = N(variable: S("Y", .variable))
            return N(symbol: S("f", .function(2)), nodes: [X, Y])
        }

        func pfxyz() -> N {
            let Z = N(variable: S("Z", .variable))
            let fXY = fxy()
            return N(symbol: S("p", .predicate(2)), nodes: [fXY, Z])
        }

        print("Perfect sharing")
        print("Create 'p(f(X,Y),Z)'")
        let p = pfxyz()
        print("'p(f(X,Y),Z)':", p)

        print("Create 'f(X,Y)'")
        let f = fxy()
        print("'f(X,Y)':", f)

        print("Perfect sharing")
        print("Create 'p(f(X,Y),Z)'")
        let q = pfxyz()
        print("'p(f(X,Y),Z)':", q)

        print("all nodes", N.pool)

        return N.pool.count
    }
}

private func demoShow<N: Node>(nodes: [N])
    where N: AnyObject, N: SymbolStringTyped {
    print("nodes:\(nodes).count=\(nodes.count)")

    for s in Set(nodes) {
        let v = s.isVariable ? ", variable" : ""
        let c = s.isConstant ? ", constant" : ""
        print("'\(s)''\(v)\(c), variables:\(s.variables), \(s.subnodes)")
    }

    for (i, a) in nodes.enumerated() {
        for (j, b) in nodes.enumerated().map({ $0 })[(i + 1) ..< nodes.count] {
            guard a == b else { continue }
            let s = a === b ? "===" : ">-<"
            print("\(a) == \(b) : #\(i) \(s) #\(j)")
        }
    }
}

/// MARK: - Parsing

import Foundation // URL

extension Demo {
    struct Problem {
        static func parseCnf() -> Int {
            typealias NodeType = Demo.KinNode
            let problem = cnfProblem

            let inputs: [NodeType] = demoParse(problem: problem)
            for (i, input) in inputs.enumerated() {
                if show { print(i, input) }
                guard input.variables.count > 0 else { continue }
                if show { print("⊥", input⊥) }
            }

            if show { print("Node == \(String(reflecting: NodeType.self))") }
            return inputs.count
        }

        static func parseFof() -> Int {
            typealias NodeType = Demo.KinNode
            let problem = fofProblem

            let inputs: [NodeType] = demoParse(problem: problem)
            if show {
                for (i, input) in inputs.enumerated() {
                    print(i, input.description)
                }

                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }

        static func parseHWV() -> Int {
            typealias NodeType = Demo.KinNode
            let problem = hwvProblem

            let inputs: [NodeType] = demoParse(problem: problem)
            if show {
                for (i, input) in inputs.enumerated() {
                    print(i, input.description)
                }

                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }

        static func broken() -> Int {
            typealias NodeType = Demo.KinNode
            let problem = "Package.swift"

            let inputs: [NodeType] = demoParse(problem: problem)
            if show {
                for (i, input) in inputs.enumerated() {
                    print(i, input.description)
                }
                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }

        static func simpleNode() -> Int {
            typealias NodeType = Demo.SimpleNode

            let inputs: [NodeType] = demoParse(problem: hwvProblem)
            if show { print(hwvProblem, "count :", inputs.count) }

            guard inputs.count > 0 else { return 0 }

            if show {
                print("#1", inputs[0])
                print("#1", inputs[0].debugDescription)
                print("#\(inputs.count)", inputs[inputs.count - 1].debugDescription)
                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }

        static func sharingNode() -> Int {
            typealias NodeType = Demo.SharingNode

            let inputs: [NodeType] = demoParse(problem: hwvProblem)
            if show { print(hwvProblem, "count :", inputs.count) }

            guard inputs.count > 0 else { return 0 }

            if show {
                print("#1", inputs[0])
                print("#1", inputs[0].debugDescription)
                print("#\(inputs.count)", inputs[inputs.count - 1].debugDescription)

                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }

        static func smartNode() -> Int {
            typealias NodeType = Demo.SmartNode

            let inputs: [NodeType] = demoParse(problem: hwvProblem)
            if show { print(hwvProblem, "count :", inputs.count) }

            guard inputs.count > 0 else { return 0 }

            if show {
                print("#1", inputs[0])
                print("#1", inputs[0].debugDescription)
                print("#\(inputs.count)", inputs[inputs.count - 1].debugDescription)

                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }

        static func kinNode() -> Int {
            typealias NodeType = Demo.KinNode

            let inputs: [NodeType] = demoParse(problem: hwvProblem)
            if show { print(hwvProblem, "count :", inputs.count) }

            guard inputs.count > 0 else { return 0 }

            if show {
                print("#1", inputs[0])
                print("#1", inputs[0].debugDescription)
                print("#\(inputs.count)", inputs[inputs.count - 1].debugDescription)

                print("Node == \(String(reflecting: NodeType.self))")
            }
            return inputs.count
        }
    }
}

func demoParse<N: Node>(problem: String, show: Bool = Demo.show) -> [N]
    where N: SymbolStringTyped {
    if show { print("N:Node == \(String(reflecting: N.self))") }

    guard let url = URL(fileURLWithProblem: problem) else {
        if show { print("FileURL for '\(problem)' could not be found.") }
        return [N]()
    }

    let (parseResult, parseTime) = utileMeasure {
        Tptp.File(url: url)
    }
    guard let tptpFile = parseResult else {
        if show { print("\(url.relativePath) could not be parsed.") }
        return [N]()
    }
    if show { print("parse time: \(parseTime) '\(url.relativePath)'") }

    let (countResult, countTime) = utileMeasure {
        tptpFile.inputs.reduce(0) { a, _ in a + 1 }
    }

    if show { print("count=\(countResult), time=\(countTime) '\(url.relativePath)'") }

    let (result, time) = utileMeasure {
        // tptpFile.inputs.map { N(tree:$0) }
        tptpFile.ast() as N?
    }

    guard let inputs = result?.nodes else {
        if show { print("\(url.relativePath) did not convert to \(N.self)") }
        return [N]()
    }

    if show { print("init=\(result!.nodes!.count), time=\(time) '\(url.relativePath)'") }

    return inputs
}

extension Demo {

    struct Prover {
        private final class TestNode: SymbolStringTyped, SymbolTabulating, Sharing, Node,
            ExpressibleByStringLiteral {
            typealias S = Int
            typealias N = TestNode
            static var symbols = StringIntegerTable<S>()
            static var pool = WeakSet<N>()
            // var folks = WeakSet<N>() // protocol Kin

            var symbol: S = N.symbolize(string: Tptp.wildcard, type: .variable)
            var nodes: [N]?

            var description: String { return defaultDescription }
            lazy var hashValue: Int = self.defaultHashValue
        }

        static func succ() -> Int {
            Yices.setUp()

            defer {
                Yices.tearDown()
            }

            let axioms: [TestNode] = [
                "@cnf s(X) != zero",
                "s(X)!=s(Y) | X = Y",
                // "@cnf s(s(s(s(s(s(s(X))))))) = zero",
            ]

            let prover = Proverlet(axioms: axioms)

            for run in 1 ... 10 {
                let satisfiable = prover.runSequentially(timeout: 30)
                print(run, prover.clauseCount, prover.ignoreCount, satisfiable)
            }

            return 0
        }
    }
}
