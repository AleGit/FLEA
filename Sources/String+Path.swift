
import Foundation

typealias FilePath = String

extension FilePath {
  var pathComponents : [FilePath] {
    return self.components(separatedBy:"/")
  }

  ///
  var lastPathComponent : String {
    return self.pathComponents.last ?? self
  }

  func appending(component:String) -> String {
    let cs = self.pathComponents + component.pathComponents
    return cs.joined(separator:"/")
  }

  /// find accessible path to problem file by problem name
  /// "PUZ001-1".p => "./PUZ001.p" ?? "tptp_root/Problems/PUZ/PUZ001-1.p"
  var p : FilePath? {
    // accept every accessible file (with arbitray suffixes),
    // e.g. 'noproblem.txt' or ''/absolute/path/to/problem.txt'
    if self.isAccessible { return self }

    // append '.p' if necessary,
    // e.g. 'PUZ001+1' => 'PUZ001+1.p' or
    // 'Problems/PUZ001-1' => 'Problems/PUZ001-1.p'
    var path = self.hasSuffix(".p") ? self : self.appending(".p")
    // accept every accessible file with suffix '.p'
    if path.isAccessible { return path }

    path = path.lastPathComponent
    if path.isAccessible { return path }

    // insert three letter prefix (TPTP file structure convention),
    // e.g. 'PUZ001-1.p' => 'PUZ/PUZ001-1.p'
    // but 'PUZ/PUZ001-1.p' => 'PUZ/PUZ001-1.p'
    let endIndex = path.index(path.startIndex, offsetBy:3)
    let prefix = path[path.startIndex..<endIndex]
    path = prefix.appending(component:path)
    if path.isAccessible { return path }

    path = "Problems".appending(component:path)
    print(path)
    if path.isAccessible { return path }

    print(FilePath.tptpRoot?.appending(component:path))

    if let absolutePath = (FilePath.tptpRoot)?.appending(component:path)
    where absolutePath.isAccessible {
      return absolutePath
    }

    return nil
  }

  /// '/a/path/to/Problems/folders' -> /a/path/to/
  /// '/from/Problems/to/Problems/folders' -> /from/Problems/to/
  var problemsPrefix : String {
    let separator = "Problems"
    var cs = self.components(separatedBy:separator)

    cs.removeLast()
    return cs.joined(separator:separator)
  }

  /// Find path to axiom
  func pathTo(axiom:String) -> FilePath? {
    if axiom.isAccessible { return axiom }

    let path = self.hasSuffix(".ax") ? self : self.appending(".ax")
    if path.isAccessible { return path }

    let root = self.problemsPrefix

    let relativePath = root.appending("Axioms").appending(axiom.lastPathComponent)
    if relativePath.isAccessible { return relativePath }

    if let absolutePath = FilePath.tptpRoot?.appending(component:axiom.lastPathComponent)
    where absolutePath.isAccessible { return absolutePath }

    return axiom.ax
  }


   var ax : FilePath? {
    if self.isAccessible { return self }

    var path = self.hasSuffix(".ax") ? self : self.appending(".ax")
    if path.isAccessible { return path }

    path = path.lastPathComponent
    if path.isAccessible { return path }

    path = "Axioms".appending(component:path)
    if path.isAccessible { return path }

    if let absolutePath = (FilePath.tptpRoot)?.appending(component:path)
    where absolutePath.isAccessible {
      return absolutePath
    }

    return nil
  }
}

extension FilePath {

  private static var home : FilePath? {
    return Process.Environment.getValue(for:"HOME")
  }

  static var tptpRoot : FilePath? {

    // process option --tptp_root has the highest priority
    if let option = Process.option(name:"--tptp_root") {
      if let path = option.settings.first(where:{$0.isAccessibleDirectory}) {
        return path
      }
      else {
        print("WARNING: Option\(option) includes no accessible directory!")
      }
    }

    // try to read tptp root from environment
    if let path = Process.Environment.getValue(for:"TPTP_ROOT")
    where path.isAccessibleDirectory {
      return path
    }

    // home directory has a low priority
    if let path = FilePath.home?.appending("/TPTP")
    where path.isAccessibleDirectory {
      return path
    }

    // ~/Downloads has a very low priority
    if let path = FilePath.home?.appending("/Downloads/TPTP")
    where path.isAccessibleDirectory {
      return path
    }

    // * no tptp root directory available
    return nil
  }

  var fileSize : Int? {
    var status = stat()

    let code = stat(self, &status)
    switch (code, S_IFREG & status.st_mode) {
      case (0,S_IFREG):
        return Int(status.st_size)
        default:
          return nil
        }
    // guard code == 0 else { return nil }
    // return Int(status.st_size)
  }

  var isAccessible : Bool {
    guard let f = fopen(self,"r") else {
      return false
    }
    fclose(f)
    return true
  }

  var isAccessibleDirectory : Bool {
    guard let d = opendir(self) else {
      return false
    }
    closedir(d)
    return self.isAccessible
  }


      // var fileSize : Int? {
      //   guard let attributes = try? FileManager.default.attributesOfItem(atPath:self) else {
      //     return nil
      //   }
      //
      //   guard let size = attributes[FileAttributeKey.size] else {
      //     return nil
      //   }
      //
      //   return size.intValue
      // }
      //
      // var isAccessible : Bool {
      //   // Remark: everthing, e.g. a directory, is a file
      //   return FileManager.default.isReadableFile(atPath:self)
      // }
      //
      // var isAccessibleDirectory : Bool {
      //
      //   guard self.isAccessible else { return false }
      //
      //   var isDirectory : ObjCBool = false
      //
      //   guard FileManager.default.fileExists(atPath:self, isDirectory:&isDirectory) else { return false }
      //
      //   return isDirectory.boolValue
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