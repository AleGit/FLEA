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

    deinit {
      print("\(#function) \(self.symbol).\(self.c)")
    }
  }
}
