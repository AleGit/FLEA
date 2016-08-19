import Foundation
import XCTest
@testable import FLEA

let ok = "✅ "
let nok = "❌ "

public class FleaTestCase : XCTestCase {
  override class public func setUp() {
    super.setUp()
    print("+++ FleaTestCase.\(#function) +++")
  }
  override class public func tearDown() {
    print("=== FleaTestCase.\(#function) ===")
    super.tearDown()
  }
}

public class YicesTestCase : FleaTestCase {
  override class public func setUp() {
    super.setUp()
    Yices.setUp()
  }
  override class public func tearDown() {
    Yices.tearDown()
    super.tearDown()
  }
}

struct Q {
  typealias Node = Tptp.SmartNode

  static var X = Node(v:"X")
  static var Y = Node(v:"Y")
  static var Z = Node(v:"Z")
  static var a = Node(c:"a")
  static var b = Node(c:"b")
  static var c = Node(c:"c")

  static var fXY = Node(f:"f",[X,Y])
  static var fXZ = fXY * [Y:Z]
  static var fYZ = fXZ * [X:Y]
  static var fXX = fXY * X

  static var gXYZ = Node(f:"g",[X,Y,Z])
  static var hX = Node(f:"h",[X])

  static var X_a = [X:a]
  static var Y_b = [Y:b]
  static var Z_c = [Z:c]

  static var fab = fXY * [X:a,Y:b]
  static var faa = fXY * [X:a,Y:a]
  static var gabc = gXYZ * [X:a,Y:b,Z:c]
  static var ha = hX * [X:a]

  static var ffaaZ = Node(f:"f",[faa,Z])
}

extension Q {
  static func parse<N:FLEA.Node>(problem:String) -> [N] 
  where N:SymbolStringTyped {
    print("N:Node == \(String(reflecting:N.self))")

    guard let url = URL(fileURLwithProblem:problem) else {
      print("Path for '\(problem)' could not be found.")
      return [N]()
    }

    let (parseResult, parseTime) = utileMeasure {
      FLEA.Tptp.File(url:url)
    }
    guard let tptpFile = parseResult else {
        print("\(url.relativePath) could not be parsed.")
        return [N]()
    }
    print("parse time: \(parseTime) '\(url.relativePath)'")

    let (countResult, countTime) = utileMeasure {
      tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
    }

    print("count=\(countResult), time=\(countTime) '\(url.relativePath)'")

    let (result,time) = utileMeasure {
      // tptpFile.inputs.map { N(tree:$0) }
      tptpFile.ast() as N?
    }

    guard let inputs = result?.nodes else {
      print("\(url.relativePath) did not convert to \(N.self)")
      return [N]()
    }

    print("init=\(result!.nodes!.count), time=\(time) '\(url.relativePath)'")

    print(problem, "count :", inputs.count)

    guard inputs.count > 0 else { return [N]() }

    print("#1", inputs[0])

    print("Node == \(String(reflecting:N.self))")
    return inputs
  }
}
