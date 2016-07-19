#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

extension Process {
  typealias Option = (name:String,params:[String])

  /// Process.arguments may fail internally when Process.argc == 0
  private static var args : [String] {
    guard Process.argc > 0 else { return [String]() }
    return Process.arguments
  }

  private static func get (option name: String) -> [String]? {

    guard name.hasPrefix("--") else {
      return nil
    }

    guard let startIndex = Process.args.index(of:name) else {
      return nil
    }

    let s = Array(Process.args.suffix(from:startIndex+1))

    guard let endIndex = s.index(where: { $0.hasPrefix("--")} ) else {
      return s
    }

    return Array(s[0..<endIndex])

  }

  static var options : [Option] = Process.args.filter { $0.hasPrefix("--") }.map {
    (name:$0, params:Process.get(option:$0)!)
  }

  static func option(name:String) -> Option? {
    return Process.options.first {$0.name == name}

  }

  struct Environment {
    static func getValue(for name: String) -> String? {
      guard let value = getenv(name) else { return nil }
      return String(validatingUTF8: value)
    }
    private static func deletValue(for name: String) {
      unsetenv(name)
    }
    private static func set(value:String, for name: String, overwrite: Bool = true) {
      setenv(name, value, overwrite ? 1 : 0)
    }
  }


}
