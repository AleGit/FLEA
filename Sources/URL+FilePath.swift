
import Foundation

/// Some functions and properties have an optional return type on Linux,
/// while an non optional on macOS.
func optional<T>(_ value:T?) -> T? {
  return value
}

extension URL {
  static var tptpDirectoryURL : URL? {

    // --tptp_root has the highest priority
    if let path = CommandLine.options["--tptp_root"]?.first,
    path.isAccessibleDirectory {
      return URL(fileURLWithPath: path)
    }

    // the environment has a high priority
    if let path = CommandLine.Environment.getValue(for:"TPTP_ROOT")
    , path.isAccessibleDirectory {
      return URL(fileURLWithPath: path)
    }

    // home directory has a medium priority
    if let url = URL.homeDirectoryURL?.appending(component:"/TPTP")
    , url.isAccessibleDirectory {
      Syslog.notice { "fallback to \(url.relativeString)"}
      return url
    }

    // ~/Downloads has a very low priority
    if let url = URL.homeDirectoryURL?.appending(component:"/Downloads/TPTP")
    , url.isAccessibleDirectory {
      Syslog.notice { "fallback to \(url.relativeString)"}
      return url
    }

    return nil
  }

  static var homeDirectoryURL : URL? {

    guard let path = CommandLine.Environment.getValue(for:"HOME") else {
      return nil
    }
    return URL(fileURLWithPath: path)
  }

  static var loggingConfigurationURL : URL? {
    // --config path/to/file
    if let path = CommandLine.options["--config"]?.first, path.isAccessible {
      return URL(fileURLWithPath: path)
    }

    // FLEA_CONFIGS_PATH not supported yet
    // FLEA_CONFIG not supported yet
    // logging.<name.extension> not supperted yet

    let url = URL(fileURLWithPath:CommandLine.name)

    // macOS: lastPathComponent : String
    // Linux: lastPathComponent : String?
    Syslog.warning { "optional(url.lastPathComponent)" }
    if let name = optional(url.pathExtension) {
      let url = URL(fileURLWithPath:"Configs/\(name).logging")
      if url.isAccessible { return url }
      
      print(url,"is not accessible")
    }
    
    return URL(fileURLWithPath: "Configs/default.logging")


    
  }
}

/// with Swift 3 Preview 4/5 the URL signatures diverged between macOS and linux
/// these workaround will not build when signatures change
extension URL {
  var pathOrEmpty : String {
    #if os(OSX)
    return self.path
    #elseif os(Linux)
    return self.path ?? ""
    #endif
  }
  var extensionOrEmpty : String {
    #if os(OSX)
    return self.pathExtension
    #elseif os(Linux)
    return self.pathExtension ?? ""
    #endif
  }
  var lastComponentOrEmpty : String {
    #if os(OSX)
    return self.lastPathComponent
    #elseif os(Linux)
    return self.lastPathComponent ?? ""
    #endif

  }
  fileprivate mutating func deleteExtension() {
    #if os(OSX)
    self.deletePathExtension()
    #elseif os(Linux)
    try? self.deletePathExtension()
    #endif
  }
  fileprivate func deletingExtension() -> URL {
    var url = self
    url.deleteExtension()
    return url
  }

  fileprivate mutating func deleteLastComponent() {
    #if os(OSX)
    self.deleteLastPathComponent()
    #elseif os(Linux)
    try? self.deleteLastPathComponent()
    #endif
  }

  fileprivate func deletingLastComponent() -> URL {
    var url = self
    url.deleteLastComponent()
    return url
  }

  fileprivate mutating func deleteLastComponents(downTo c:String) {
    var deleted = false
    while !deleted && self.lastPathComponent != "/" {
      if self.lastPathComponent == c {
        deleted = true
      }
      self.deleteLastComponent()
    }
  }

  fileprivate func deletingLastComponents(downTo c:String) -> URL {
    var url = self
    url.deleteLastComponent()
    return url
  }

  fileprivate mutating func append(extension pex:String, delete:Bool = true) {
    let pe = self.extensionOrEmpty
    guard pe != pex else { return } // nothing to do

    if delete { self.deleteExtension() }

    #if os(OSX)
    self.appendPathExtension(pex)
    #elseif os(Linux)
    try? self.appendPathExtension(pex)
    #endif
  }

  fileprivate func appending(extension pex:String, delete:Bool = true) -> URL {
    var url = self
    url.append(extension:pex, delete:delete)
    return url
  }

  fileprivate mutating func append(component c:String) {
    #if os(OSX)
    self.appendPathComponent(c)
    #elseif os(Linux)
    try? self.appendPathComponent(c)
    #endif
  }

  fileprivate func appending(component c:String) -> URL{
    var url = self
    url.append(component:c)
    return url
  }
}

extension URL {
  fileprivate init?(fileURLwithTptp name:String, ex:String,
    roots:URL?...,
    f:((String)->String)? = nil) {

    self = URL(fileURLWithPath:name)
    self.append(extension:ex)

    var names = [name]
    if let rs = optional(self.relativePath), !names.contains(rs) {
      names.append(rs)
    }

    let lastComponent = self.lastComponentOrEmpty
    if !lastComponent.isEmpty {
      if !names.contains(lastComponent) {
        names.append(lastComponent)
      }
      if let g = f?(lastComponent), !names.contains(g) {
        names.append(g)
      }
    }

    for base in roots.flatMap({ $0 }) {
      for name in names {
        for url in [URL(fileURLWithPath:name), base.appending(component:name)] {
          if url.isAccessible {
            self = url
            return
          }
        }
      }
    }
    return nil
  }
}

extension URL {
  /// a problem string is either
  /// - the name of a problem file, e.g. 'PUZ001-1[.p]'
  /// - the relative path to a file, e.g. 'relative/path/PUZ001-1[.p]'
  /// - the absolute path to a file, e.g. '/path/to/dir/PUZ001-1[.p]'
  /// with or without extension 'p'.
  /// If no resolved problem file path is accessible, nil is returned.
  init?(fileURLwithProblem problem:String) {
    guard let url = URL(fileURLwithTptp: problem, ex:"p",
      roots: // start search in ...
      // $TPTP_ROOT/
      URL.tptpDirectoryURL, // $TPTP_ROOT/Problems/PUZ/PUZ001-1.ps
      // $HOME/TPTP/
      URL.homeDirectoryURL?.appending(component:"TPTP"), // fallback
      f: {
        let abc = $0[$0.startIndex..<($0.index($0.startIndex, offsetBy:3))]
        return "Problems/\(abc)/\($0)"
      }
    ) else { return nil }

    self = url
  }

  /// an axiom string is either
  /// - the name of a axiom file, e.g. 'PUZ001-1[.ax]'
  /// - the relative path to a file, e.g. 'relative/path/PUZ001-1[.ax]'
  /// - the absolute path to a file, e.g. '/path/to/dir/PUZ001-1[.ax]'
  /// with or without extension 'ax'.
  /// If a problem URL is given, the axiom file is searches on a position in the
  /// file tree parallel to the problem file.
  /// If no resolved axiom file path is accessible, nil is returned.
  init?(fileURLwithAxiom axiom:String, problemURL:URL? = nil) {
    guard let url = URL(fileURLwithTptp: axiom, ex:"ax",
      roots: // start search in ...
      // $Y/problem.p -> $Y/
      problemURL?.deletingLastComponent(),
      // $Y/Problems[/ppath]/p.p -> $Y/
      problemURL?.deletingLastComponents(downTo:"Problems"),
      // $TPTP_ROOT/
      URL.tptpDirectoryURL,
      // $HOME/TPTP/
      URL.homeDirectoryURL?.appending(component:"TPTP"),
      f: { "Axioms/\($0)" }
    ) else { return nil }

    self = url

  }
}

extension URL {
  var isAccessible : Bool {
    return optional(self.path)?.isAccessible ?? false
  }

  var isAccessibleDirectory : Bool {
    return optional(self.path)?.isAccessibleDirectory ?? false
  }
}

typealias FilePath = String

extension FilePath {
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
      Syslog.info { "Path \(self) is not accessible."}
      return false
    }
    fclose(f)
    return true
  }

  var isAccessibleDirectory : Bool {
    guard let d = opendir(self) else {
      Syslog.info { "Directory \(self) does not exist."}
      return false
    }
    closedir(d)
    return self.isAccessible
  }
}

extension FilePath {
  var content : String? {
    #if os(OSX) /**************************************************************/

    return try? String(contentsOfFile:self)

    #elseif os(Linux) /********************************************************/

    Syslog.notice {
      "#Linux #workaround : init(contentsOfFile:usedEncoding:) is not yet implemented."
    }

    guard let f = fopen(self,"r") else {
      return nil
    }
    defer { fclose(f) }

    guard let bufsize = self.fileSize else {
      return nil
    }
    var buf = [CChar](repeating:CChar(0), count:bufsize+16)
    guard fread(&buf, 1, bufsize, f) == bufsize else { return nil }
    return String(validatingUTF8:buf)

    #endif  /******************************************************************/
  }
}

extension String {
  var lines:[String] {

    defer { Syslog.debug { ": [String]" } }

    #if os(OSX) /**************************************************************/

    var result = [String]()
    enumerateLines {
      (l,_) -> () in
      result.append(l)
    }
    return result
     
    #elseif os (Linux) /*******************************************************/
    // fatal error: enumerateSubstrings(in:options:using:) is not yet implemented: file Foundation/NSString.swift, line 810

    Syslog.notice { Syslog.Tags.system() + " " + Syslog.Tags.workaround() }
    return self.components(separatedBy:"\n")

    #endif /********************************************************/
  }

  var trimmingWhitespace : String {
    return self.trimmingCharacters(in: CharacterSet.whitespaces)
  }

  var pealing : String {
    let start = self.index(after:self.startIndex)
    let end = self.index(before:self.endIndex)
    return self.substring(with:start..<end)
  }
}
