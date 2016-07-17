
struct Demo {
  static let line = Array(repeating:"=", count:80).joined(separator:"")

  static let demos = [
  "puz001-1" : Demo.Problem.puz001cnf,
  "puz001+1" : Demo.Problem.puz001fof,
  "hwv134-1" : Demo.Problem.hwv134cnf,
  // "noshare" : Demo.Node.demo,
  // "sharing" : Demo.SharingNode.demo
  ]



  static func demo() {
    // check if ther are arguments all and if the first argument is `--demo`
    guard Process.arguments.count > 1 && Process.arguments[1] == "--demo"
    else { return }

    // check if there are any argumenst after `--demo`
    if Process.arguments.count == 2 {
      let keys = demos.map { $0.0 }
      let prefix = "  $ \(Process.arguments[0]) --demo"
      print("You've selected '--demo' with no list of demos.")
      print("  \(keys)")
      print("To execute all demos type the following line:")
      let args = demos.map { $0 }.reduce(prefix) { $0 + " \($1.0)"}
        print(args)
      }

      for n in Process.arguments[2..<Process.arguments.count] {
        print(line)
        guard let f = demos[n] else {
          print("DEMO '\(n)' does not exist.")
          continue
        }
        print("MEASURE DEMO '\(n)'")
        let (_,runtime) = measure(f:f)
        print("RUNTIME OF DEMO '\(n)'",runtime)
      }
    }
  }
