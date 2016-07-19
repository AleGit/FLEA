
public struct Demo {
  static let line = Array(repeating:"=", count:80).joined(separator:"")

  static let demos = [
  "p1c" : (Demo.Problem.puz001cnf,"Parse PUZ001-1 (cnf)"),
  "p1f" : (Demo.Problem.puz001fof,"Parse PUZ001+1 (fof)"),
  "hwv" : (Demo.Problem.hwv134cnf,"Parse HWV134-1"),
  "broken" : (Demo.Problem.broken,"Parse invalid file"),
  "share" : (Demo.sharing, "Node sharing"),
  "mgu" : (Demo.Unification.demo,"Unfication")
  // "noshare" : Demo.Node.demo,
  // "sharing" : Demo.SharingNode.demo
  ]



  public static func demo() {
      guard let names = Process.option(name:"--demo")?.1 else {
        return
      }

      guard names.count > 0 else {

        print("You've selected '--demo' with no list of demos.")
        for (key,value) in demos {
          print("   '\(key)' \tdescription:'\(value.1)")

        }
        let prefix = "  $ \(Process.arguments[0]) --demo"
        print("To execute all demos type the following line:")
        let args = demos.map { $0 }.reduce(prefix) { $0 + " \($1.0)"}
          print(args)
          return
        }

      for n in names {
        print(line)
        guard let f = demos[n]?.0 else {
          print("DEMO '\(n)' does not exist.")
          continue
        }
        print("MEASURE DEMO '\(n)'")
        let (_,runtime) = measure(f:f)
        print("RUNTIME OF DEMO '\(n)'",runtime)
      }
    }
  }
