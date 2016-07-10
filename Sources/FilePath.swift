#if os(Linux)
import Glibc
#else
import Darwin
#endif

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

      var isAccessibleDirectory : Bool {
        let d = opendir(self)
        guard d != nil else {
          return false
        }
        closedir(d)
        return true
      }

      var isAccessibleFile : Bool {
        let f = fopen(self,"r")
        guard f != nil else {
          return false
        }
        fclose(f)
        return true
      }
    }
    
    extension FilePath {
      static func demo() {
        print("\(#file).\(#function)")

        for path in ["Sources/main.swift", "Sources", "Problems", "main.swift", "Folder"] {
          print("'\(path)'.isAccessibleFile = \(path.isAccessibleFile)")
          print("'\(path)'.isAccessibleDirectory = \(path.isAccessibleDirectory)")

          print("'\(path)'.fileSize = \(path.fileSize)")
        }
      }
    }
