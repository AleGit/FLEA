extension Demo {
  final class Node : FLEA.Node {
    var symbol = Tptp.Symbol("n/a",.Undefined)
    var nodes : [Demo.Node]? = nil
  }

  final class SharingNode : FLEA.SharingNode {
    static var counter = 0

    static var allNodes = Set<Demo.SharingNode>()

    var symbol = Tptp.Symbol("n/a",.Undefined)
    var nodes : [Demo.SharingNode]? = nil
    var c : Int = {
      let a = SharingNode.counter
      SharingNode.counter += 1
      return a
    }()

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.tptpDescription

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



private func demoShow<N:Node where N:AnyObject>(nodes:[N]) {
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

private func demoCreateNodes<N:Node where N:AnyObject, N.Symbol == String>() -> [N] {
  let v = [
  N(variable:"X"),
  N(constant:"a"),
  N(constant:"a"),
  N(variable:"Y")]

  let f = [
  N(symbol:"f", nodes:v[1...2]),
  N(symbol:"g", nodes:v[0...0]),
  N(symbol:"g", nodes:v[2...2]),
  N(symbol:"f", nodes:[ v[3], v[0] ])
  ]

  let p = [ N(symbol:"p", nodes:[f[0], v[1]]),
  N(symbol:"q", nodes:[f[1]]),
  N(symbol:"q", nodes:[f[2]]),
  N(symbol:"p", nodes:[f[3], v[3]])
  ]
  return v + f + p
}
