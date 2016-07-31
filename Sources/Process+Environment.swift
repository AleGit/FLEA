#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

extension Process {
  typealias Option = (name:String,settings:[String])

  /// Process.arguments.first ?? "n/a"
  static var name : String {
    guard Process.argc > 0 else {
      // `guard Process.arguments.count > 0 else ...`
      // fails when argc == 0, e.g. while unit testing
      // Process.arguments.count causes an unwrap error
      return "n/a"
    }
    return Process.arguments[0]
  }

  /// Process.arguments.dropFirst()
  static var parameters : [String] {
    guard Process.argc > 0 else {
      // `guard Process.arguments.count > 0 else ...`
      // fails when argc == 0, e.g. while unit testing
      // Process.arguments.count causes an unwrap error
      return [String]()
    }
    return Array(Process.arguments.dropFirst())
  }

  /// get option settings
  /// --A a b c --B d -e --C d
  /// get(option:"--A") -> ["a","b","c"]
  /// get(option:"--B") -> ["d","-e"]
  /// get(option:"--C") -> ["d"]
  private static func get (option name: String) -> [String]? {

    guard name.hasPrefix("--") else {
      return nil // not an option
    }

    guard let startIndex = Process.parameters.index(of:name) else {
      return nil // option not found in parameters
    }

    let s = Array(Process.parameters.suffix(from:startIndex+1))

    guard let endIndex = s.index(where: { $0.hasPrefix("--")} ) else {
      return s
    }

    return Array(s[0..<endIndex])

  }

  private static var options : [Option] = Process.parameters.filter { $0.hasPrefix("--") }.map {
    (name:$0, settings:Process.get(option:$0)!)
  }

  static func option(name:String) -> Option? {
    // return Process.options.first {$0.name == name}
    guard let settings = Process.get(option:name) else {
      return nil
    }
    return (name, settings)
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
