extension Demo {
  struct Problem {

    static func puz001cnf() {
      typealias NodeType = Tptp.Node
      let problem = "PUZ001-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      for (i,input) in inputs.enumerated() {
        print(i,input)
        guard input.variables.count > 0 else { continue }
        print("⊥", input⊥)
      }

      print("Node == \(String(reflecting:NodeType.self))")
    }

    static func puz001fof() {
      typealias NodeType = Tptp.Node
      let problem = "Problems/PUZ001+1"

      let inputs : [NodeType] = demoParse(problem:problem)
      for (i,input) in inputs.enumerated() {
        print(i,input.description)
      }

      print("Node == \(String(reflecting:NodeType.self))")
    }

    static func broken() {
      typealias NodeType = Tptp.Node
      let problem = "Package.swift"

      let inputs : [NodeType] = demoParse(problem:problem)
      for (i,input) in inputs.enumerated() {
        print(i,input.description)
      }

      print("Node == \(String(reflecting:NodeType.self))")
    }

     static func simpleNode() {
      typealias NodeType = Tptp.SimpleNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      print(problem, "count :", inputs.count)

      guard inputs.count > 0 else { return }

      print("#1", inputs[0])
      print("#1", inputs[0].debugDescription)
      print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

      print("Node == \(String(reflecting:NodeType.self))")
    }
     static func sharingNode() {
      typealias NodeType = Tptp.SharingNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      print(problem, "count :", inputs.count)

      guard inputs.count > 0 else { return }

      print("#1", inputs[0])
      print("#1", inputs[0].debugDescription)
      print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

      print("Node == \(String(reflecting:NodeType.self))")
    }
     static func smartNode() {
      typealias NodeType = Tptp.SmartNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      print(problem, "count :", inputs.count)

      guard inputs.count > 0 else { return }

      print("#1", inputs[0])
      print("#1", inputs[0].debugDescription)
      print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

      print("Node == \(String(reflecting:NodeType.self))")
    }
     static func kinNode() {
      typealias NodeType = Tptp.KinNode
      let problem = "Problems/HWV134-1"

      let inputs : [NodeType] = demoParse(problem:problem)
      print(problem, "count :", inputs.count)

      guard inputs.count > 0 else { return }

      print("#1", inputs[0])
      print("#1", inputs[0].debugDescription)
      print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

      print("Node == \(String(reflecting:NodeType.self))")
    }
  }
}

func demoParse<N:Node>(problem:String) -> [N] {
  print("N:Node == \(String(reflecting:N.self))")

  guard let path = problem.p else {
    print("Path for '\(problem)' could not be found.")
    return [N]()
  }

  let (parseResult, parseTime) = measure {
    Tptp.File(path:path)
  }
  guard let tptpFile = parseResult else {
      print("\(path) could not be parsed.")
      return [N]()
  }
  print("parse time: \(parseTime) '\(path)'")

  let (countResult, countTime) = measure {
    tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
  }

  print("count=\(countResult), time=\(countTime) '\(path)'")

  let (result,time) = measure {
    // tptpFile.inputs.map { N(tree:$0) }
    tptpFile.ast() as N?
  }

  guard let inputs = result?.nodes else {
    print("\(path) did not convert to \(N.self)")
    return [N]()
  }

  print("init=\(result!.nodes!.count), time=\(time) '\(path)'")

  return inputs
}
