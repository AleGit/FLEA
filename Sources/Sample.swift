struct Sample {
  final class Node : FLEA.Node {

    var symbol: String = ""
    var nodes : [Sample.Node]? = nil

  }

  final class SharingNode : FLEA.SharingNode {
    typealias S = Set<Sample.SharingNode>

      static var sharedNodes = Set<Sample.SharingNode>()

      var symbol: String = ""
      var nodes : [Sample.SharingNode]? = nil
  }
}
