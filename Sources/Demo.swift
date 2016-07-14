
struct Demo {

  static let demos = [
    "PUZ001cnf" : Demo.puz001cnf,
    "PUZ001fof" : Demo.puz001fof,
    "HWV134cnf" : Demo.hwv134cnf
  ]

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

  static func demo() {
    guard Process.arguments.count > 1 && Process.arguments[1] == "--demo"
    else {
      return
    }

    if Process.arguments.count == 2 {
      let args = demos.map { $0 }.reduce("--demo") { $0 + " \($1.0)"}
      print(args)
    }

    for n in Process.arguments[2..<Process.arguments.count] {
      guard let f = demos[n] else {
        print("DEMO '\(n)' does not exist.")
        continue
      }
      print("MEASURE DEMO '\(n)'")
      let (_,runtime) = measure(f:f)
      print("RUNTIME OF DEMO '\(n)'",runtime)
    }





  }

  private static func hwv134() {
    print("\(#function)")
    defer {
      print("\(#function) DONE")
    }

    let (tptpFile,runtime) = measure {
      TptpFile(path:"/Users/Shared/TPTP/Problems/HWV/HWV134-1.p")
    }
    print(tptpFile, runtime)
  }


  private static func files() {
    print("\(#function)")
    defer {
      print("\(#function) DONE")
    }

    for path in ["Problems/PUZ001-1.p", "Problems/PUZ002-1.p", "Problems",
    "Problems/PUZ001+1.p"] {
      print(">", path,path.fileSize, path.isAccessibleDirectory, path.isAccessible)
      let (tptpFile,runtime) = measure { TptpFile(path:path) }
      print(path,runtime)
      if let tptpFile = tptpFile {
        tptpFile.printInputs()
      }
    }
  }



}
