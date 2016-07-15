struct Sample {
  final class Node : FLEA.Node {
    var symbol: String = ""
    var nodes : [Sample.Node]? = nil
  }

  final class SharingNode : FLEA.SharingNode {
    static var counter = 0

    static var sharedNodes = Set<Sample.SharingNode>()

    var symbol: String = ""
    var nodes : [Sample.SharingNode]? = nil
    var c : Int = {
      let a = SharingNode.counter
      SharingNode.counter += 1
      return a
    }()

    lazy var hashValue : Int = self.calcHashValue()
    lazy var description : String = self.tptpDescription()

    deinit {
      print("\(#function) \(self.symbol).\(self.c)")
    }
  }
}

private func sampleShowNodes<N:Node where N:AnyObject>(nodes:[N]) {
  print(nodes.count, nodes, Set(nodes))

  for (i, a) in nodes.enumerated() {
    for (j,b) in nodes.enumerated().map({$0})[(i+1)..<nodes.count] {
      if (a == b) {
        print("\(a)#\(i) === \(b)#\(j)", a===b) }
      }
  }
}

private func sampleCreateNodes<N:Node where N:AnyObject, N.Symbol == String>() -> [N] {
  let v = [
    N(symbol:"X"),
    N(symbol:"Y",nodes:nil),
    N(symbol:"X",nodes:nil),
    N(symbol:"Y")
  ]
  let f = [
    N(symbol:"f", nodes:v[1...2]),
    N(symbol:"g", nodes:v[0...0]),
    N(symbol:"g", nodes:v[2...2]),
    N(symbol:"f", nodes:[ v[3], v[0] ])
  ]

  let p = [
  N(symbol:"p", nodes:[f[0], v[1]]),
  N(symbol:"q", nodes:[f[1]]),
  N(symbol:"q", nodes:[f[2]]),
  N(symbol:"p", nodes:[f[3], v[3]])
  ]
  return v + f + p
}



extension Sample.Node {
  typealias N = Sample.Node
  static func demo() {
    let nodes : [N] = sampleCreateNodes()
    sampleShowNodes(nodes:nodes)
  }
}

extension Sample.SharingNode {
  typealias N = Sample.SharingNode
  static func demo() {
      let nodes : [N] = sampleCreateNodes()
      sampleShowNodes(nodes:nodes)
  }
}
