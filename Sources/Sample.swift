struct Sample {
  final class Node : FLEA.Node {
    static func share (node: Node) -> Node { return node }

    var symbol: String = ""
    var nodes : [Sample.Node]? = nil
  }

  final class SharingNode : FLEA.Node {

      static var sharedNodes = Set<Sample.SharingNode>()

      static func share (node:SharingNode) -> SharingNode {
        if let index = sharedNodes.index(of:node) {
          return sharedNodes[index]
        }
        else {
          sharedNodes.insert(node)
          return node
        }
      }

      var symbol: String = ""
      var nodes : [Sample.SharingNode]? = nil
  }
}
