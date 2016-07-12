#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

typealias FilePath = String

extension FilePath {

  var fileSize : Int? {
    guard let attributes = try? FileManager.default.attributesOfItem(atPath:self) else {
      return nil
    }

    guard let size = attributes[FileAttributeKey.size] else {
      return nil
    }

    return size.intValue
  }

  var isAccessible : Bool {
    // Remark: everthing, e.g. a directory, is a file
    return FileManager.default.isReadableFile(atPath:self)
  }

  var isAccessibleDirectory : Bool {

    guard self.isAccessible else { return false }

    var isDirectory : ObjCBool = false

    guard FileManager.default.fileExists(atPath:self, isDirectory:&isDirectory) else { return false }

    return isDirectory.boolValue
  }

  // var fileSize : Int? {
  //   var status = stat()
  //   let code = stat(self, &status)
  //   switch (code, S_IFREG & status.st_mode) {
  //     case (0,S_IFREG):
  //       return Int(status.st_size)
  //     default:
  //       // Nylog.warn("\(code) \(status.st_mode)")
  //       return nil
  //     }
  //   }

  // var isAccessibleFile : Bool {
  //   guard let f = fopen(self,"r") else {
  //     return false
  //   }
  //   fclose(f)
  //   return true
  // }

  // var isAccessibleDirectory : Bool {
  //   guard let d = opendir(self) else {
  //     return false
  //   }
  //   closedir(d)
  //   return true
  // }
}

extension FilePath {
  static func demo() {
    print("\(#file).\(#function)")

    for path in ["README.md", "Sources/main.swift", "Sources", "Problems", "main.swift", "/Users/aXm/", "/Users/aXm/ldir", "/Users/aXm/lfil"] {
      print("'\(path)'.isAccessible = \(path.isAccessible)")
      print("'\(path)'.isAccessibleDirectory = \(path.isAccessibleDirectory)")

      print("'\(path)'.fileSize = \(path.fileSize)")
    }
  }
}
