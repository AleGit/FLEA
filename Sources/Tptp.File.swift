import CTptpParsing

import Foundation

extension Tptp {
    /// A parsed TPTP file where the abstract syntax tree is stored in an optimized
    /// dynamically allocated heap memory which is only accessible by pointers.
    /// (it uses TptpParsingLib with C-API)
    final class File {

        private var store: StoreRef?
        /// The root of the parsed <TPTP_file>
        /// <TPTP_file> ::= <TPTP_input>*
        private(set) var root: TreeNodeRef?

        /// intiialize with the content of a file referenced by file path
        private init?(path: FilePath) {
            Syslog.notice { "Tptp.File(path:\(path))" }
            guard let size = path.fileSize, size > 0 else {
                return nil
            }
            let code = prlcParsePath(path, &store, &root)
            guard code == 0 && self.store != nil && self.root != nil else {
                return nil
            }
        }

        /// intiialize with the content of a file referenced by file url
        convenience init?(url: URL) {
            Syslog.info { "Tptp.File(url:\(url))" }

            if url.isFileURL {
                let path = url.path
                Syslog.debug { "url.path : \(type(of: url.path))" }
                self.init(path: path)
            } else {
                Syslog.error { "\(url) is not a file URL!" }
                // TODO: Download file into
                // - canonical place and parse the saved file
                // - memory and parse string of type .file
                return nil
            }
        }

        /// Searches for a problem by name, convention, and TPTP Path,
        /// e.g. "PUZ001-1" => ~/TPTP/Problems/PUZ001-1p
        /// It will return nil if problem file could not be located, read or parsed.
        convenience init?(problem name: String) {
            Syslog.info { "Tptp.File(problem:\(name))" }
            guard let url = URL(fileURLWithProblem: name) else {
                Syslog.error { "Problem \(name) could not be found." }
                return nil
            }
            self.init(url: url)
        }

        /// Search and parse an axiom file by name, problem url, conventions, and TPTP Path,
        /// e.g. the search starts relatively to the problem file.
        /// It will return nil if axiom file could not be located, read or parsed.
        @available(*, deprecated, message: "- unused, see TPTP.File.includeSelectionURLTriples -")
        convenience init?(axiom name: String, problemURL: URL?) {
            guard let url = URL(fileURLWithAxiom: name, problemURL: problemURL) else {
                Syslog.error { "Axiom \(name) could not be found. (Problem: \(problemURL?.path ?? String.NIL))" }
                return nil
            }
            self.init(url: url)
        }

        // initialize with the content of string
        init?(string: String, type: Tptp.SymbolType) {
            Syslog.notice { "Tptp.File(string:\(string), type:\(type))" }

            let code: Int32

            switch type {
                /// variables and (constant) are terms.
                /// Σ -> fof(temp, axiom, predicate(Σ)).
                /// http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html#plain_term
            case .function(_), .variable:
                code = prlcParseString(string, &store, &root, PRLC_FUNCTION)

                /// conjunctive normal form
                /// Σ -> string -> cnf(temp, axiom, Σ).
                /// http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html#cnf_annotated
            case .cnf:
                code = prlcParseString(string, &store, &root, PRLC_CNF)

                /// arbitrary first order formulas
                /// Σ -> fof(temp, axiom, Σ).
                /// http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html#fof_annotated
            case .fof, .universal, .existential, .negation, .disjunction, .conjunction,
                 .implication, .reverseimpl, .bicondition, .xor, .nand, .nor,
                 .equation, .inequation, .predicate:

                code = prlcParseString(string, &store, &root, PRLC_FOF)

                /// the content of include statements, e.g.
                /// - "'Axioms/PUZ001-0.ax'"
                /// - "'Axioms/SYN000-0.ax',[ia1,ia3]"
                /// Σ -> include(Σ).
                /// http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html#include
            case .include:
                code = prlcParseString(string, &store, &root, PRLC_INCLUDE)

                /// the content of a file
                /// Σ -> Σ
                /// http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html#TPTP_file
            case .file:
                code = prlcParseString(string, &store, &root, PRLC_FILE)

            default: // .name, .role, .annotation
                code = -1
            }

            guard code == 0 && store != nil && root != nil else {
                return nil
            }
        }

        /// free dynammically allocated memory
        deinit {
            Syslog.debug { "'\(self.path ?? String.NIL)' memory freed." }
            if let store = store {
                prlcDestroyStore(store)
            }
        }

        /// Transform the C tree representation into a Swift representation.
        func ast<N: Node>() -> N?
            where N: SymbolNameTyped {
            guard let tree = self.root else { return nil }
            let t: N = N(tree: tree)
            return t
        }

        /// The path to the parsed file is stored in the root.
        var path: FilePath? {
            guard let cstring = root?.pointee.symbol else { return nil }
            return String(validatingUTF8: cstring) ?? nil
        }

        var url: URL? {
            guard let path = self.path else { return nil }
            return URL(fileURLWithPath: path)
        }

        /// The sequence of parsed <TPTP_input> nodes.
        /// - <TPTP_input> ::= <annotated_formula> | <include>
        var inputs: UtileSequence<TreeNodeRef, TreeNodeRef> {
            return root!.children { $0 }
        }

        /// The sequence of stored symbols (paths, names, etc.) from first to last.
        /// Symbols (C-strings / UTF8) are uniquely stored in a single memory block,
        /// i.e. the symbols are separated by exactly one `\0`
        private var symbols: UtileSequence<CStringRef, String?> {
            let first = prlcFirstSymbol(self.store!)
            let step = {
                (cstring: CStringRef) in
                prlcNextSymbol(self.store!, cstring)
            }
            let data = {
                (cstring: CStringRef) in
                String(validatingUTF8: cstring)
            }

            return UtileSequence(first: first, step: step, data: data)
        }

        /// The sequence of stored tree nodes from first to last.
        private var nodes: UtileSequence<TreeNodeRef, TreeNodeRef> {
            let first = prlcFirstTreeNode(self.store!)
            let step = {
                (treeNode: TreeNodeRef) in
                prlcNextTreeNode(self.store!, treeNode)
            }
            let data = {
                (treeNode: TreeNodeRef) in
                treeNode
            }
            return UtileSequence(first: first, step: step, data: data)
        }

        /// The sequence of parsed <include> nodes.
        /// includes.count <= inputs.count
        private var includes: UtileSequence<TreeNodeRef, TreeNodeRef> {
            return root!.children(where: { $0.type == PRLC_INCLUDE }) { $0 }
        }

        /// The sequence of parsed <cnf_annotated> nodes.
        /// cnfs.count <= inputs.count
        // private
        var cnfs: UtileSequence<TreeNodeRef, TreeNodeRef> {
            return root!.children(where: { $0.type == PRLC_CNF }) { $0 }
        }

        /// The sequence of parsed <fof_annotated> nodes.
        /// fofs.count <= inputs.count
        private var fofs: UtileSequence<TreeNodeRef, TreeNodeRef> {
            return root!.children(where: { $0.type == PRLC_FOF }) { $0 }
        }

        func nameRoleClauseTriples<N: Node>(predicate: (String, Tptp.Role) -> Bool = { _, _ in true })
            -> [(String, Tptp.Role, N)]
            where N: SymbolNameTyped {
            return cnfs.flatMap {
                guard let name = $0.symbol,
                    let child = $0.child,
                    let string = child.symbol,
                    let role = Tptp.Role(rawValue: string),
                    let cnf = child.sibling else {
                    let symbol = $0.symbol ?? "n/a"
                    Syslog.error { "Invalid cnf \(symbol) in '\(self.path ?? String.NIL)'" }
                    return nil
                }
                guard predicate(name, role) else {
                    // name and role did not pass the test
                    return nil
                }
                let tree = N(tree: cnf)
                Syslog.debug { "\(tree)" }
                return (name, role, tree)
            }
        }

        /// return a list of triples with local file name, formula selection, and file URL
        /// from <include> entries like "include('Axioms/SYN000+0.ax',[ia1,ia3]).":
        /// e.g.("'Axioms/SYN000+0.ax'", ["ia1","ia3"], "${HOME}/TPTP/Axioms/SYN000+0.ax")
        func includeSelectionURLTriples(url: URL) -> [(String, [String], URL)] {
            // <include> ::= include(<file_name><formula_selection>).

            return includes.flatMap {
                // <file_name> ::= <single_quoted>
                guard let name = $0.symbol else {
                    Syslog.error { "<include> entry has no <file_name>." }
                    return nil
                }
                guard let fileURL = URL(fileURLWithAxiom: name, problemURL: url) else {
                    Syslog.error { "fileURL for \(name) was not found. (problemURL: \(url.path))" }
                    return nil
                }
                // <formula_selection> ::= ,[<name_list>] | <null>
                let selection = $0.children.flatMap {
                    $0.symbol
                }
                return (name, selection, fileURL)
            }
        }

        var containsIncludes: Bool {
            return self.includes.reduce(false) { _, _ in true }
        }
    }
}
