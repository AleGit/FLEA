
public struct Demo {
  static let line = Array(repeating:"=", count:80).joined(separator:"")

  static var show : Bool = true

  static let demos = [
  "p1c" : (Demo.Problem.puz001cnf,"Parse PUZ001-1 (cnf)"),
  "p1f" : (Demo.Problem.puz001fof,"Parse PUZ001+1 (fof)"),
  // "hwv" : (Demo.Problem.hwv134cnf,"Parse HWV134-1 (expensive)"),
  "simple" : (Demo.Problem.simpleNode,"Parse HWV134-1 with simple node(expensive)"),
  "sharing" : (Demo.Problem.sharingNode,"Parse HWV134-1 with sharing node (expensive)"),
  "smart" : (Demo.Problem.smartNode,"Parse HWV134-1 with smart node (expensive)"),
  "Kin" : (Demo.Problem.kinNode,"Parse HWV134-1 with kin node (expensive)"),
  "broken" : (Demo.Problem.broken,"Parse invalid file"),
  "pool" : (Demo.sharing, "Node sharing"),
  "mgu" : (Demo.Unification.demo,"Unfication")
  ]

  public static func demo() -> Int? {
    guard let names = Process.option(name:"--demo")?.1 else {
      return nil
    }

    guard names.count > 0 else {
      print(line)
      print("You've selected '--demo' with no list of demos.")
      for (key,value) in demos {
        print("   '\(key)' \tdescription:'\(value.1)")

      }
      let prefix = "  $ \(Process.arguments[0]) --demo"
      print("To execute all demos type the following line:")
      let args = demos.map { $0 }.reduce(prefix) { $0 + " \($1.0)"}
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
      let (_,runtime) = utileMeasure(f:f)
      print("RUNTIME OF DEMO '\(n)'",runtime)
    }
    print(line)
    return names.count
  }
}


/// MARK: - Unification

extension Demo {
  struct Unification {
    static func demo() -> Int {

      // let nodes : [Tptp.Node] = demoCreateNodes()

      let X = Tptp.Node(v: "X")
      let Y = Tptp.Node(v: "Y")
      let Z = Tptp.Node(v: "Z")

      let a = Tptp.Node(c: "a")
      let b = Tptp.Node(c: "a")

      let fXY = Tptp.Node(f: "f", [X,Y])

      let fYX = fXY * [X:Y, Y:X]
      let fYZ = fXY * [X:Y, Y:Z]
      let fab = fXY * [X:a, Y:b]
      let ffabZ = fXY * [X:fab, Y:Z]

      let nodes = [ fXY, fYX, fYZ, fab, ffabZ ]

      for f in nodes {
        for g in nodes {
          guard let mgu = f =?= g else {
            print("\(f) =?= \(g) is not unifiable.")
            continue
          }
          print("\(f) =?= \(g) = \(mgu.description)")

        }
      }
      return nodes.count
    }
  }
}

/// MARK: - Node

extension Demo {
  final class Node : FLEA.Node {
    var symbol = Tptp.Symbol("",.undefined)
    var nodes : [Demo.Node]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.debugDescription
  }

  final class SharingNode : FLEA.SharingNode {
    static var counter = 0

    static var pool = Set<Demo.SharingNode>()

    var symbol = Tptp.Symbol("",.undefined)
    var nodes : [Demo.SharingNode]? = nil
    var c : Int = {
      let a = SharingNode.counter
      SharingNode.counter += 1
      return a
    }()

    init() {
      print("\(#function)#\(self.c)")
    }

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.debugDescription

    var debugDescription : String {
      guard let nodes = self.nodes?.map({$0.description}), nodes.count > 0
      else {
        return "\(self.symbol)'\(self.c)"
      }
      let tuple = nodes.map{ $0 }.joined(separator:",")
      return "\(self.symbol)'\(self.c)(\(tuple))"
    }

    deinit {
      print("\(#function)#\(self.c): \(self)")
    }
  }
}

// extension Demo.Node {
//   typealias N = Demo.Node
//   static func demo() {
//     let nodes : [N] = demoCreateNodes()
//     demoShow(nodes:nodes)
//   }
// }
//
// extension Demo.SharingNode {
//   typealias N = Demo.SharingNode
//   static func demo() {
//     let nodes : [N] = demoCreateNodes()
//     demoShow(nodes:nodes)
//   }
// }
extension Demo {
  static func sharing() -> Int {
    typealias N = Demo.SharingNode
    typealias S = Tptp.Symbol


    func fxy() -> N {
      let X = N(variable:S("X",.variable))
      let Y = N(variable:S("Y",.variable))
      return N(symbol:S("f",.function(2)), nodes: [ X, Y ])
    }

    func pfxyz() -> N {
      let Z = N(variable:S("Z",.variable))
      let fXY = fxy()
      return N(symbol:S("p",.predicate(2)), nodes: [fXY, Z])

    }

    print("Perfect sharing")
    print("Create 'p(f(X,Y),Z)'")
    let p  = pfxyz()
    print("'p(f(X,Y),Z)':",p)


    print("Create 'f(X,Y)'")
    let f  = fxy()
    print("'f(X,Y)':",f)

    print("Perfect sharing")
    print("Create 'p(f(X,Y),Z)'")
    let q  = pfxyz()
    print("'p(f(X,Y),Z)':",q)


    print("all nodes", N.pool)

    return N.pool.count

  }
}



private func demoShow<N:Node where N:AnyObject, N.Symbol:Symbolable>(nodes:[N]) {
  print("nodes:\(nodes).count=\(nodes.count)")

  for s in Set(nodes) {
    let v = s.isVariable ? ", variable" : ""
    let c = s.isConstant ? ", constant" : ""
    print("'\(s)''\(v)\(c), variables:\(s.variables), \(s.subnodes)")
  }

  for (i, a) in nodes.enumerated() {
    for (j,b) in nodes.enumerated().map({$0})[(i+1)..<nodes.count] {
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
    static func puz001cnf() -> Int {
      typealias NodeType = Tptp.Node
      let problem = "PUZ001-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      for (i,input) in inputs.enumerated() {
        if show {print(i,input)}
        guard input.variables.count > 0 else { continue }
        if show {print("⊥", input⊥)}
      }

      if show {print("Node == \(String(reflecting:NodeType.self))")}
      return inputs.count
    }

    static func puz001fof() -> Int {
      typealias NodeType = Tptp.Node
      let problem = "Problems/PUZ001+1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show {
        for (i,input) in inputs.enumerated() {
          print(i,input.description)
        }

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }

    static func broken() -> Int {
      typealias NodeType = Tptp.Node
      let problem = "Package.swift"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show {
        for (i,input) in inputs.enumerated() {
          print(i,input.description)
        }
        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }

    static func simpleNode() -> Int {
      typealias NodeType = Tptp.SimpleNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)
        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
    static func sharingNode() -> Int {
      typealias NodeType = Tptp.SharingNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
    static func smartNode() -> Int {
      typealias NodeType = Tptp.SmartNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
    static func kinNode() -> Int {
      typealias NodeType = Tptp.KinNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
  }
}

func demoParse<N:Node where N.Symbol:Symbolable>(problem:String, show:Bool = Demo.show) -> [N] {
  if show{print("N:Node == \(String(reflecting:N.self))")}

  guard let path = problem.p else {
    if show{print("Path for '\(problem)' could not be found.")}
    return [N]()
  }

  let (parseResult, parseTime) = utileMeasure {
    Tptp.File(url:URL(fileURLWithPath:path))
  }
  guard let tptpFile = parseResult else {
    if show {print("\(path) could not be parsed.")}
    return [N]()
  }
  if show {print("parse time: \(parseTime) '\(path)'")}

  let (countResult, countTime) = utileMeasure {
    tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
  }

  if show {print("count=\(countResult), time=\(countTime) '\(path)'")}

  let (result,time) = utileMeasure {
    // tptpFile.inputs.map { N(tree:$0) }
    tptpFile.ast() as N?
  }

  guard let inputs = result?.nodes else {
    if show {print("\(path) did not convert to \(N.self)")}
    return [N]()
  }

  if show {print("init=\(result!.nodes!.count), time=\(time) '\(path)'")}

  return inputs
}
