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
      let inputs : [Demo.Node] = demoParseFile(path:path)
      for (i,input) in inputs.enumerated() {
        print(i,input)
      }
    }

    static func hwv134cnf() {
      let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
      let inputs : [Tptp.Node] = demoParseFile(path:path)
      print(path, "count :", inputs.count)
      print("#1", inputs[0])
      print("#\(inputs.count)",inputs[inputs.count-1])
    }
  }
}
func demoParseFile<N:Node where N.Symbol == String>(path:String) -> [N] {
  guard let tptpFile = TptpFile(path:path) else {
    print("\(path) could not be parsed.")
    return [N]()
  }
  let count = tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
  let (inputs,runtime) = measure {
    tptpFile.inputs.map { N(tree:$0) }
  }
  print(path, count, inputs.count)
  print("runtime",runtime)
  return inputs
}
