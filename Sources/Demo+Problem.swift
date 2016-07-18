extension Demo {
  struct Problem {

    static func puz001cnf() {
      typealias NodeType = Tptp.Node
      let path = "Problems/PUZ001-1.p"

      let inputs : [NodeType] = demoParseFile(path:path)
      for (i,input) in inputs.enumerated() {
        print(i,input)
        guard input.variables.count > 0 else { continue }
        print("⊥", input⊥)
      }

      print("Node == \(String(reflecting:NodeType.self))")
    }

    static func puz001fof() {
      typealias NodeType = Tptp.Node
      let path = "Problems/PUZ001+1.p"

      let inputs : [NodeType] = demoParseFile(path:path)
      for (i,input) in inputs.enumerated() {
        print(i,input.description)
      }

      print("Node == \(String(reflecting:NodeType.self))")
    }

    static func hwv134cnf() {
      typealias NodeType = Tptp.Node
      let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"

      let inputs : [NodeType] = demoParseFile(path:path)
      print(path, "count :", inputs.count)

      guard inputs.count > 0 else { return }

      print("#1", inputs[0])
      print("#1", inputs[0].debugDescription)
      print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)

      print("Node == \(String(reflecting:NodeType.self))")
    }
  }
}

func demoParseFile<N:Node>(path:String) -> [N] {
  print("N:Node == \(String(reflecting:N.self))")

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
