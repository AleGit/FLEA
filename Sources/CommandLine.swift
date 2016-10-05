#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

public extension CommandLine {
  public typealias Option = (name: String, settings: [String])

  /// CommandLine.arguments.first ?? "n/a"
  public static var name: String {
    guard CommandLine.argc > 0 else {
      Syslog.error { "CommandLine has no arguments." }

      assert(false, "CommandLine has no arguments.")
      // `guard CommandLine.arguments.count > 0 else ...`
      // fails when argc == 0, e.g. while unit testing
      // CommandLine.arguments.count causes an unwrap error
      return "n/a (CommandLine has no arguments.)"

      // appears to be corrected at Swift 3 Preview 5/6
    }
    return CommandLine.arguments[0]
  }

  /// CommandLine.arguments.dropFirst()
  public static var parameters: [String] {
    guard CommandLine.argc > 0 else {
      // `guard CommandLine.arguments.count > 0 else ...`
      // fails when argc == 0, e.g. while unit testing
      // CommandLine.arguments.count causes an unwrap error
      return [String]()
    }
    return Array(CommandLine.arguments.dropFirst())
  }

  static var options: [String : [String]] = {
    var dictionary = ["" : [String]()]
    var name = ""
    for parameter in CommandLine.parameters {
      if parameter.hasPrefix("--") {
        name = parameter
        if dictionary[name] == nil {
          dictionary[name] = [String]()
        }
      } else {
        /// --A 1 2 4 --B 5 --C -A 7
        // "" : []
        // "--A" : 1,2,4,7
        // "--B" : 5
        // "--C" : []
        dictionary[name]?.append(parameter)
       }
     }
     #if DEBUG
     print("options", dictionary)
     #endif
      return dictionary
    }()

  // public static func option(name:String) -> Option? {
  //   guard let settings = options[name] else { return nil }
  //   return (name, settings)
  // }

  struct Environment {
    static func getValue(for name: String) -> String? {
      guard let value = getenv(name) else { return nil }
      return String(validatingUTF8: value)
    }
    private static func deletValue(for name: String) {
      unsetenv(name)
    }
    private static func set(value: String, for name: String, overwrite: Bool = true) {
      setenv(name, value, overwrite ? 1 : 0)
    }
  }
}
