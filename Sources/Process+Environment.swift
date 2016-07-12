#if os(Linux)
import Glibc
#else
import Darwin
#endif

import CoreFoundation

extension Process {
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
