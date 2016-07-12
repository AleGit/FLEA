#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

typealias FilePath = String

extension FilePath {
  var fileSize : Int? {
    var status = stat()
    let code = stat(self, &status)
    switch (code, S_IFREG & status.st_mode) {
      case (0,S_IFREG):
        return Int(status.st_size)
        default:
          // Nylog.warn("\(code) \(status.st_mode)")
          return nil
        }
      }

  // var isAccessibleDirectory : Bool {
  //   guard let d = opendir(self) else {
  //     return false
  //   }
  //   closedir(d)
  //   return true
  // }

  var isAccessibleDirectory : Bool {

    guard self.isAccessible else { return false }

    var isDirectory : ObjCBool = false

    guard FileManager.default.fileExists(atPath:self, isDirectory:&isDirectory) else { return false }

    return isDirectory.boolValue
  }

  var isAccessible : Bool {
    // Remark: a directory, everthing is file
    return FileManager.default.isReadableFile(atPath:self)
  }

  // var isAccessibleFile : Bool {
  //   guard let f = fopen(self,"r") else {
  //     return false
  //   }
  //   fclose(f)
  //   return true
  // }
}

extension FilePath {
  static func demo() {
    print("\(#file).\(#function)")

    for path in ["Sources/main.swift", "Sources", "Problems", "main.swift", "/Users/aXm/", "/Users/aXm/ldir", "/Users/aXm/lfil"] {
      print("'\(path)'.isAccessible = \(path.isAccessible)")
      print("'\(path)'.isAccessibleDirectory = \(path.isAccessibleDirectory)")

      print("'\(path)'.fileSize = \(path.fileSize)")
    }
  }
}
