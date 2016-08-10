
import Foundation

/// Some funcition habe an optional return type on linux,
///  while an non optional on macOS.
func optional<T>(_ value:T?) -> T? {
  return value
}

extension URL {
  static var tptpDirectoryURL : URL? {
    guard let path = String.tptpDirectoryPath else {
      return nil
    }
    return URL(fileURLWithPath: path)
  }

  static var homeDirectoryURL : URL? {
    guard let path = String.homeDirectoryPath else {
      return nil
    }
    return URL(fileURLWithPath: path)
  }
}

/// with Swift 3 Preview 4 the URL signatures diverged between macOS and linux
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
  private mutating func deleteExtension() {
    #if os(OSX)
    self.deletePathExtension()
    #elseif os(Linux)
    try? self.deletePathExtension()
    #endif
  }
  private func deletingExtension() -> URL {
    var url = self
    url.deleteExtension()
    return url
  }

  private mutating func deleteLastComponent() {
    #if os(OSX)
    self.deleteLastPathComponent()
    #elseif os(Linux)
    try? self.deleteLastPathComponent()
    #endif
  }

  private func deletingLastComponent() -> URL {
    var url = self
    url.deleteLastComponent()
    return url
  }

  private mutating func deleteLastComponents(downTo c:String) {
    var deleted = false
    while !deleted && self.lastPathComponent != "/" {
      if self.lastPathComponent == c {
        deleted = true
      }
      self.deleteLastComponent()
    }
  }

  private func deletingLastComponents(downTo c:String) -> URL {
    var url = self
    url.deleteLastComponent()
    return url
  }

  private mutating func append(extension pex:String, delete:Bool = true) {
    let pe = self.extensionOrEmpty
    guard pe != pex else { return } // nothing to do

    if delete { self.deleteExtension() }

    #if os(OSX)
    self.appendPathExtension(pex)
    #elseif os(Linux)
    try? self.appendPathExtension(pex)
    #endif
  }

  private func appending(extension pex:String, delete:Bool = true) -> URL {
    var url = self
    url.append(extension:pex, delete:delete)
    return url
  }

  private mutating func append(component c:String) {
    #if os(OSX)
    self.appendPathComponent(c)
    #elseif os(Linux)
    try? self.appendPathComponent(c)
    #endif
  }

  private func appending(component c:String) -> URL{
    var url = self
    url.append(component:c)
    return url
  }
}

extension URL {
  private init?(fileURLwithTptp name:String, ex:String,
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
    let optional : String? = self.path
    return optional?.isAccessible ?? false
  }
}

typealias FilePath = String

extension FilePath {
  private var pathComponents : [FilePath] {
    return self.components(separatedBy:"/")
  }

  ///
  var lastPathComponent : String {
    return self.pathComponents.last ?? self
  }

  private func appending(component:String) -> String {
    let cs = self.pathComponents + component.pathComponents
    return cs.joined(separator:"/")
  }

  /// find accessible path to problem file by problem name
  /// "PUZ001-1".p => "./PUZ001.p" ?? "tptp_root/Problems/PUZ/PUZ001-1.p"
  @available(*, deprecated:1.0, message:"Use URL(fileURLwithProblem:) instead.")
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

    print(FilePath.tptpDirectoryPath?.appending(component:path))

    if let absolutePath = (FilePath.tptpDirectoryPath)?.appending(component:path),
    absolutePath.isAccessible {
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

    if let absolutePath = FilePath.tptpDirectoryPath?.appending(component:axiom.lastPathComponent),
    absolutePath.isAccessible { return absolutePath }

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

    if let absolutePath = (FilePath.tptpDirectoryPath)?.appending(component:path)
    , absolutePath.isAccessible {
      return absolutePath
    }

    return nil
  }
}

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

extension FilePath {
  private static var homeDirectoryPath : String? {
    return Process.Environment.getValue(for:"HOME")
  }

  private static var tptpDirectoryPath : FilePath? {

    // process option --tptp_root has the highest priority
    if let option = Process.option(name:"--tptp_root") {
      if let path = option.settings.first(where:{$0.isAccessibleDirectory}) {
        return path
      }
      else {
        Syslog.warning {
          "Option \(option) includes no accessible directory!"
        }
      }
    }

    // try to read tptp root from environment
    if let path = Process.Environment.getValue(for:"TPTP_ROOT")
    , path.isAccessibleDirectory {
      return path
    }

    // home directory has a low priority
    if let path = FilePath.homeDirectoryPath?.appending("/TPTP")
    , path.isAccessibleDirectory {
      return path
    }

    // ~/Downloads has a very low priority
    if let path = FilePath.homeDirectoryPath?.appending("/Downloads/TPTP")
    , path.isAccessibleDirectory {
      return path
    }

    // * no tptp root directory available
    return nil
  }
}

extension FilePath {
  static var configPath : FilePath? {
    if let path = Process.option(name:"--config")?.settings.first, path.isAccessible {
      print(path,Process.name)
      return path
    }

    var p : FilePath? = nil
    switch Process.name {
      case "n/a":
        p = "Config/xctest.default"
      case let n where n.hasSuffix("xctest"):
          p = "Config/xctest.default"

      default:
            p = "Config/default.default"
    }
    if let path = p, path.isAccessible { return path }

    return nil
  }
}

extension String {
  var lines:[String] {
    #if os(OSX) /**************************************************************/

    var result = [String]()
    enumerateLines {
      (l,_) -> () in
      result.append(l)
    }
    return result

    #elseif os (Linux) /*******************************************************/

    Syslog.notice { Syslog.Tags.system() + " " + Syslog.Tags.workaround() }
    return self.components(separatedBy:"\n")

    #endif /********************************************************/
  }

  var trimmingWhitespace : String {
    #if os(OSX) /**************************************************************/

    return self.trimmingCharacters(in: CharacterSet.whitespaces)

    #elseif os(Linux) /********************************************************/

    Syslog.debug {  Syslog.Tags.system() + " " + Syslog.Tags.workaround() }
    var cs = self.characters
    while let f = cs.first, f == " " || f == "\t" {
      cs.removeFirst()
    }
    while let l = cs.last, l == " " || l == "\t" {
      cs.removeLast()
    }
    return String(cs)

    #endif /*******************************************************************/
  }
}
