

@testable import FLEA

let ok = "✅ "
let nok = "❌ "
let err = "⛔️ "

struct Q {

  typealias Node = SmartNode

  static var X = Node(variable:"X")
  static var Y = Node(variable:"Y")
  static var Z = Node(variable:"Z")
  static var a = Node(constant:"a")
  static var b = Node(constant:"b")
  static var c = Node(constant:"c")

  static var fXY = Node(symbol:"f",nodes:[X,Y])
  static var gXYZ = Node(symbol:"g",nodes:[X,Y,Z])
  static var hX = Node(symbol:"h",nodes:[X])

  static var X_a = [X:a]
  static var Y_b = [Y:b]
  static var Z_c = [Z:c]

  static var fab = fXY * [X:a,Y:b]
  static var faa = fXY * [X:a,Y:a]
  static var gabc = gXYZ * [X:a,Y:b,Z:c]
  static var ha = hX * [X:a]

  static var ffaaZ = Node(symbol:"f",nodes:[faa,Z])
}

extension Q {

  final class SmartNode : FLEA.SmartNode {
    static var allNodes = WeakCollection<SmartNode>()

    var symbol = ""
    var nodes : [SmartNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription

    deinit {
      print("\(#function) \(self)")
    }
  }
}

extension Q {

  final class SharingNode : FLEA.SharingNode {
    static var allNodes = Set<SharingNode>()

    var symbol = ""
    var nodes : [SharingNode]? = nil

    lazy var hashValue : Int = self.defaultHashValue
    lazy var description : String = self.defaultDescription

    deinit {
      print("\(#function) \(self)")
    }
  }
}
