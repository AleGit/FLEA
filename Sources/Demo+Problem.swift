extension Demo {
  struct Problem {

    static func puz001cnf() {
      let path = "Problems/PUZ001-1.p"
      guard let tptpFile = TptpFile(path:path) else {
        print("\(path) could not be parsed.")
        return
      }
      tptpFile.printInputs()
    }

    static func puz001fof() {
      let path = "Problems/PUZ001+1.p"
      guard let tptpFile = TptpFile(path:path) else {
        print("\(path) could not be parsed.")
        return
      }
      tptpFile.printInputs()
    }

    static func hwv134cnf() {
      let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
      guard let tptpFile = TptpFile(path:path) else {
        print("\(path) could not be parsed.")
        return
      }
      let count = tptpFile.inputs.reduce(0) { (a,_) in a + 1 }
      print(path, count)
    }
  }
}
