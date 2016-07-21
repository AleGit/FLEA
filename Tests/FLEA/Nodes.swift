

@testable import FLEA

let ok = "✅ "
let nok = "❌ "
let err = "⛔️ "

struct Q {

  typealias Node = Tptp.SmartNode

  static var X = Node(variable:"X")
  static var Y = Node(variable:"Y")
  static var Z = Node(variable:"Z")
  static var a = Node(constant:"a")
  static var b = Node(constant:"b")
  static var c = Node(constant:"c")

  static var fXY = Node(symbol:"f",nodes:[X,Y])
  static var fXZ = fXY * [Y:Z]
  static var fYZ = fXZ * [X:Y]
  static var fXX = fXY * X


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
