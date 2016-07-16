extension Demo {
  struct Problem {

    static func puz001cnf() {
      let path = "Problems/PUZ001-1.p"
      let inputs : [Demo.Node] = demoParseFile(path:path)
      for (i,input) in inputs.enumerated() {
        print(i,input)
      }
    }

    static func puz001fof() {
      let path = "Problems/PUZ001+1.p"
      let inputs : [Tptp.Node] = demoParseFile(path:path)
      for (i,input) in inputs.enumerated() {
        print(i,input)
        print(i,input.debugDescription)
      }
    }

    static func hwv134cnf() {
      let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
      let inputs : [Tptp.Node] = demoParseFile(path:path)
      print(path, "count :", inputs.count)
      print("#1", inputs[0])

      print("#1", inputs[0].debugDescription)
      print("#\(inputs.count)",inputs[inputs.count-1].debugDescription)
    }
  }
}

func demoParseFile<N:Node>(path:String) -> [N] {
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
