

@testable import FLEA

let ok = "✅ "
let nok = "❌ "

struct Q {
  typealias Node = Tptp.SmartNode

  static var X = Node(v:"X")
  static var Y = Node(v:"Y")
  static var Z = Node(v:"Z")
  static var a = Node(c:"a")
  static var b = Node(c:"b")
  static var c = Node(c:"c")

  static var fXY = Node(f:"f",nodes:[X,Y])
  static var fXZ = fXY * [Y:Z]
  static var fYZ = fXZ * [X:Y]
  static var fXX = fXY * X

  static var gXYZ = Node(f:"g",nodes:[X,Y,Z])
  static var hX = Node(f:"h",nodes:[X])

  static var X_a = [X:a]
  static var Y_b = [Y:b]
  static var Z_c = [Z:c]

  static var fab = fXY * [X:a,Y:b]
  static var faa = fXY * [X:a,Y:a]
  static var gabc = gXYZ * [X:a,Y:b,Z:c]
  static var ha = hX * [X:a]

  static var ffaaZ = Node(f:"f",nodes:[faa,Z])
}

struct Misc {
  static func parse<N:Node>(problem:String) -> [N] {
    print("N:Node == \(String(reflecting:N.self))")

    guard let path = problem.p else {
      print("Path for '\(problem)' could not be found.")
      return [N]()
    }

    let (parseResult, parseTime) = FLEA.measure {
      FLEA.Tptp.File(path:path)
    }
    guard let tptpFile = parseResult else {
        print("\(path) could not be parsed.")
        return [N]()
    }
    print("parse time: \(parseTime) '\(path)'")

    let (countResult, countTime) = FLEA.measure {
      tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
    }

    print("count=\(countResult), time=\(countTime) '\(path)'")

    let (result,time) = FLEA.measure {
      // tptpFile.inputs.map { N(tree:$0) }
      tptpFile.ast() as N?
    }

    guard let inputs = result?.nodes else {
      print("\(path) did not convert to \(N.self)")
      return [N]()
    }

    print("init=\(result!.nodes!.count), time=\(time) '\(path)'")

    print(problem, "count :", inputs.count)

    guard inputs.count > 0 else { return [N]() }

    print("#1", inputs[0])

    print("Node == \(String(reflecting:N.self))")
    return inputs
  }
}
