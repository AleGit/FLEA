import Foundation // URL

extension Demo {
  struct Problem {

    static func puz001cnf() -> Int {
      typealias NodeType = Tptp.Node
      let problem = "PUZ001-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      for (i,input) in inputs.enumerated() {
        if show {print(i,input)}
        guard input.variables.count > 0 else { continue }
        if show {print("⊥", input⊥)}
      }

      if show {print("Node == \(String(reflecting:NodeType.self))")}
      return inputs.count
    }

    static func puz001fof() -> Int {
      typealias NodeType = Tptp.Node
      let problem = "Problems/PUZ001+1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show {
        for (i,input) in inputs.enumerated() {
          print(i,input.description)
        }

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }

    static func broken() -> Int {
      typealias NodeType = Tptp.Node
      let problem = "Package.swift"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show {
        for (i,input) in inputs.enumerated() {
          print(i,input.description)
        }
        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }

    static func simpleNode() -> Int {
      typealias NodeType = Tptp.SimpleNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)
        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
    static func sharingNode() -> Int {
      typealias NodeType = Tptp.SharingNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
    static func smartNode() -> Int {
      typealias NodeType = Tptp.SmartNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
    static func kinNode() -> Int {
      typealias NodeType = Tptp.KinNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      if show { print(problem, "count :", inputs.count) }

      guard inputs.count > 0 else { return 0 }

      if show {
        print("#1", inputs[0])
        print("#1", inputs[0].debugDescription)
        print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

        print("Node == \(String(reflecting:NodeType.self))")
      }
      return inputs.count
    }
  }
}

func demoParse<N:Node where N.Symbol:Symbolable>(problem:String, show:Bool = Demo.show) -> [N] {
  if show{print("N:Node == \(String(reflecting:N.self))")}

  guard let path = problem.p else {
    if show{print("Path for '\(problem)' could not be found.")}
    return [N]()
  }

  let (parseResult, parseTime) = utileMeasure {
    Tptp.File(url:URL(fileURLWithPath:path))
  }
  guard let tptpFile = parseResult else {
    if show {print("\(path) could not be parsed.")}
    return [N]()
  }
  if show {print("parse time: \(parseTime) '\(path)'")}

  let (countResult, countTime) = utileMeasure {
    tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
  }

  if show {print("count=\(countResult), time=\(countTime) '\(path)'")}

  let (result,time) = utileMeasure {
    // tptpFile.inputs.map { N(tree:$0) }
    tptpFile.ast() as N?
  }

  guard let inputs = result?.nodes else {
    if show {print("\(path) did not convert to \(N.self)")}
    return [N]()
  }

  if show {print("init=\(result!.nodes!.count), time=\(time) '\(path)'")}

  return inputs
}
