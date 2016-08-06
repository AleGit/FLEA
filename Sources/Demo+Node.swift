extension Demo {
  final class Node : FLEA.Node {
    var symbol = Tptp.Symbol.empty
    var nodes : [Demo.Node]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.debugDescription
  }

  final class SharingNode : FLEA.SharingNode {
    static var counter = 0

    static var pool = Set<Demo.SharingNode>()

    var symbol = Tptp.Symbol.empty
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
static func sharing() {
  typealias N = Demo.SharingNode
  typealias S = Tptp.Symbol


  func fxy() -> N {
    let X = N(variable:S("X",.variable))
    let Y = N(variable:S("Y",.variable))
    return N(symbol:S("f",.function), nodes: [ X, Y ])
  }

  func pfxyz() -> N {
    let Z = N(variable:S("Z",.variable))
    let fXY = fxy()
    return N(symbol:S("p",.predicate), nodes: [fXY, Z])

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
