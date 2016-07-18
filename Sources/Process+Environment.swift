#if os(Linux)
import Glibc
#else
import Darwin
#endif


extension Process {
  typealias Option = (name:String,params:[String])

  private static func get (option name: String) -> [String]? {

    guard name.hasPrefix("--") else {
      return nil
    }

    guard let startIndex = Process.arguments.index(of:name) else {
      return nil
    }

    let s = Array(Process.arguments.suffix(from:startIndex+1))

    guard let endIndex = s.index(where: { $0.hasPrefix("--")} ) else {
      return s
    }

    return Array(s[0..<endIndex])

  }

  static var options : [Option] = Process.arguments.filter { $0.hasPrefix("--") }.map {
    (name:$0, params:Process.get(option:$0)!)
  }

  static func option(name:String) -> Option? {
    return Process.options.first {$0.name == name}

  }

  struct Environment {
    static func get(variable name: String) -> String? {
      guard let value = getenv(name) else { return nil }
      return String(validatingUTF8: value)
    }
    static func unset(variable name: String) {
      unsetenv(name)
    }
    static func set(variable name: String, value: String, overwrite: Bool = true) {
      setenv(name, value, overwrite ? 1 : 0)
    }
  }


}
