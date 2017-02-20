import Foundation

extension URL {
    /// Search for the [TPTP library](http://www.cs.miami.edu/~tptp/) for
    /// Automated Reasoning with problems and axioms on the local file system.
    static var tptpDirectoryURL: URL? {

        // --tptp_root has the highest priority
        if let path = CommandLine.options["--tptp_root"]?.first,
            path.isAccessibleDirectory {
            return URL(fileURLWithPath: path)
        }

        // the environment has a high priority
        if let path = CommandLine.Environment.getValue(for: "TPTP_ROOT"),
            path.isAccessibleDirectory {
            return URL(fileURLWithPath: path)
        }

        // ~/TPTP in the home directory has a medium priority
        if let url = URL.homeDirectoryURL?.appending(component: "/TPTP"),
            url.isAccessibleDirectory {
            Syslog.notice { "fallback to \(url.relativeString)" }
            return url
        }

        // ~/Downloads/TPTP has a very low priority
        if let url = URL.homeDirectoryURL?.appending(component: "/Downloads/TPTP"),
            url.isAccessibleDirectory {
            Syslog.notice { "fallback to \(url.relativeString)" }
            return url
        }

        Syslog.warning { "Accessible TPTP library directory path could not be found." }

        return nil
    }

    /// Get the home path from einvironment.
    static var homeDirectoryURL: URL? {
        guard let path = CommandLine.Environment.getValue(for: "HOME") else {
            Syslog.warning { "HOME path variable was not available available." }
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    /// Get the process specific configuration file path for logging
    static var loggingConfigurationURL: URL? {
        Syslog.prinfo { "Searching logging configuration file for process '\(CommandLine.name)'." }

        // --config path/to/file has the highest priority
        if let path = CommandLine.options["--config"]?.first, path.isAccessible {
            return URL(fileURLWithPath: path)
        }

        // FLEA_CONFIGS_PATH not supported yet
        // FLEA_CONFIG not supported yet
        // logging.<name.extension> not supperted yet

        // Choose logging file name by process name
        let directory = "Configs/"
        let name = URL(fileURLWithPath: CommandLine.name).lastPathComponent
        let suffix = ".logging"

        var paths = [
            "\(directory)\(name)\(suffix)",
            "\(directory)default\(suffix)",
        ]

        if CommandLine.name.contains("/debug/") {
            paths.insert("\(directory)\(name).debug\(suffix)", at: 0)
        } else if CommandLine.name.contains("/release/") {
            paths.insert("\(directory)\(name).release\(suffix)", at: 0)
        }
        for path in paths {
            let url = URL(fileURLWithPath: path)
            if url.isAccessible {
                Syslog.prinfo {"'\(url.path)' is an accessible logging configuration file." }
                return url
            }
            Syslog.prinfo {"'\(url.path)' is not accessible." }
        }
        Syslog.prinfo {"No accessible logging configuration file was found." }
        return nil
    }
}

/// with Swift 3 Preview 4/5 the URL signatures diverged between macOS and linux
/// these workaround will not build when signatures change
extension URL {

    fileprivate mutating func deleteLastComponents(downTo cmp: String) {
        var deleted = false
        while !deleted && self.lastPathComponent != "/" {
            if self.lastPathComponent == cmp {
                deleted = true
            }
            self.deleteLastPathComponent()
        }
    }

    fileprivate func deletingLastComponents(downTo cmp: String) -> URL {
        var url = self
        url.deleteLastComponents(downTo: cmp)
        return url
    }

    fileprivate mutating func append(extension pex: String, delete: Bool = true) {
        let pe = self.pathExtension
        guard pe != pex else { return } // nothing to do

        if delete { self.deletePathExtension() }

        self.appendPathExtension(pex)
    }

    fileprivate func appending(extension pex: String, delete: Bool = true) -> URL {
        var url = self
        url.append(extension: pex, delete: delete)
        return url
    }

    fileprivate mutating func append(component cmp: String) {
        self.appendPathComponent(cmp)
    }

    fileprivate func appending(component cmp: String) -> URL {
        var url = self
        url.append(component: cmp)
        return url
    }
}

extension URL {
    fileprivate init?(fileURLWithTptp name: String, pex: String,
                      roots: URL?...,
                      foo: ((String) -> String)? = nil) {

        self = URL(fileURLWithPath: name)
        self.append(extension: pex)

        var names = [name]
        let rs = self.relativePath
        if !names.contains(rs) {
            names.append(rs)
        }

        let lastComponent = self.lastPathComponent
        if !lastComponent.isEmpty {
            if !names.contains(lastComponent) {
                names.append(lastComponent)
            }
            if let g = foo?(lastComponent), !names.contains(g) {
                names.append(g)
            }
        }

        for base in roots.flatMap({ $0 }) {
            for name in names {
                for url in [URL(fileURLWithPath: name), base.appending(component: name)] {
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
    init?(fileURLWithProblem problem: String) {
        guard let url = URL(fileURLWithTptp: problem, pex: "p",
                            roots: // start search in ...
                                // $TPTP_ROOT/
                                URL.tptpDirectoryURL, // $TPTP_ROOT/Problems/PUZ/PUZ001-1.ps
                            // $HOME/TPTP/
                            URL.homeDirectoryURL?.appending(component: "TPTP"), // fallback
                            foo: {
                                let abc = $0[$0.startIndex ..< ($0.index($0.startIndex, offsetBy: 3))]
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
    init?(fileURLWithAxiom axiom: String, problemURL: URL? = nil) {
        guard let url = URL(fileURLWithTptp: axiom, pex: "ax",
                            roots: // start search in ...
                                // $Y/problem.p -> $Y/
                                problemURL?.deletingLastPathComponent(),
                            // $Y/Problems[/ppath]/p.p -> $Y/
                            problemURL?.deletingLastComponents(downTo: "Problems"),
                            // $TPTP_ROOT/
                            URL.tptpDirectoryURL,
                            // $HOME/TPTP/
                            URL.homeDirectoryURL?.appending(component: "TPTP"),
                            foo: { "Axioms/\($0)" }
        ) else { return nil }

        self = url
    }
}

extension URL {
    var isAccessible: Bool {
        return self.path.isAccessible
    }

    var isAccessibleDirectory: Bool {
        return self.path.isAccessibleDirectory
    }
}

typealias FilePath = String

extension FilePath {
    var fileSize: Int? {
        var status = stat()

        let code = stat(self, &status)
        switch (code, S_IFREG & status.st_mode) {
        case (0, S_IFREG):
            return Int(status.st_size)
        default:
            return nil
        }
        // guard code == 0 else { return nil }
        // return Int(status.st_size)
    }

    var isAccessible: Bool {
        guard let f = fopen(self, "r") else {
            Syslog.info { "Path \(self) is not accessible." }
            return false
        }
        fclose(f)
        return true
    }

    var isAccessibleDirectory: Bool {
        guard let d = opendir(self) else {
            Syslog.info { "Directory \(self) does not exist." }
            return false
        }
        closedir(d)
        return self.isAccessible
    }
}

extension FilePath {
    var content: String? {
        #if os(OSX) /**************************************************************/

            return try? String(contentsOfFile: self)

        #elseif os(Linux) /********************************************************/

            Syslog.notice {
                "#Linux #workaround : init(contentsOfFile:usedEncoding:) is not yet implemented."
            }

            guard let f = fopen(self, "r") else {
                return nil
            }
            defer { fclose(f) }

            guard let bufsize = self.fileSize else {
                return nil
            }
            var buf = [CChar](repeating: CChar(0), count: bufsize + 16)
            guard fread(&buf, 1, bufsize, f) == bufsize else { return nil }
            return String(validatingUTF8: buf)

        #endif /******************************************************************/
    }

    func lines(predicate: (String) -> Bool = { _ in true }) -> [String]? {
        guard let f = fopen(self, "r") else {
            Syslog.error { "File at '\(self)' could not be opened." }
            return nil
        }
        guard let bufsize = self.fileSize else {
            return nil
        }

        var strings = [String]()
        var buf = [CChar](repeating: CChar(0), count: bufsize)

        while let s = fgets(&buf, Int32(bufsize), f) {
            guard
                let string = String(validatingUTF8: s)?.trimmingWhitespace,
                predicate(string) else {
                continue
            }

            strings.append(string)
        }
        return strings
    }
}

extension String {

    var trimmingWhitespace: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var pealing: String {
        let start = self.index(after: self.startIndex)
        let end = self.index(before: self.endIndex)
        return self.substring(with: start ..< end)
    }
}
