import CTptpParsing

import Foundation

extension Tptp {
  final class File {

    private var store : StoreRef?
    /// The root of the parsed <TPTP_file>
    /// <TPTP_file> ::= <TPTP_input>*
    private(set) var root : TreeNodeRef?

    private init?(path:FilePath) {
      Syslog.info { path }
      guard let size = path.fileSize, size > 0 else {
        return nil;
      }
      let code = prlcParsePath(path, &store, &root)
      guard code == 0 && self.store != nil && self.root != nil else {
        return nil
      }
    }

    convenience init?(url:URL) {
      Syslog.info { "Tptp.File(url:\(url))" }

      // Swift 3 Preview 4:
      // - Linux url.path : String?
      // - macOS url.path : String
      if url.isFileURL, let path = optional(url.path) {
        Syslog.debug { "url.path : \(type(of:url.path))"}
        self.init(path:path)
      }
      else {
        // TODO: Download file into
        // - canonical place and parse the saved file
        // - memory an parse string of type .file
        return nil
      }
    }

    init?(string:String, type: Tptp.SymbolType) {
      Syslog.info { string }

      let code : Int32

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
          .equation, .inequation, .predicate(_):

          code = prlcParseString(string, &store, &root, PRLC_FOF)

        /// include statements, e.g.
        /// - "'Axioms/PUZ001-0.ax'"
        /// - "'Axioms/PUZ002-0.ax,[a,b,c]'"
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

      guard code == 0 && self.store != nil && self.root != nil else {
        return nil
      }
    }


    deinit {
      Syslog.info { self.path }
      if let store = store {
        prlcDestroyStore(store)
      }
    }

    /// Transform the C tree representation into a Swift representation.
    func ast<N:Node>() -> N?
    where N:SymbolStringTyped {
      guard let tree = self.root else { return nil }
      let t : N = N(tree:tree)
      return t
    }

    /// The path to the parsed file is store in the root.
    var path: FilePath {
      guard let cstring = root?.pointee.symbol else { return "n/a" }
      return String(validatingUTF8:cstring) ?? "n/a"
    }

    /// The sequence of parsed <TPTP_input> nodes.
    /// - <TPTP_input> ::= <annotated_formula> | <include>
    var inputs : UtileSequence<TreeNodeRef,TreeNodeRef>{
      return root!.children { $0 }
    }

    /// The sequence of stored symbols (paths, names, etc.)
    /// from first to last.
    private var symbols : UtileSequence<CStringRef,String?> {
      let first = prlcFirstSymbol(self.store!)
      let step = {
        (cstring : CStringRef) in
        prlcNextSymbol(self.store!,cstring)
      }
      let data = {
        (cstring : CStringRef) in
        String(validatingUTF8:cstring)
      }

      return UtileSequence(first:first, step:step, data:data)
    }

    /// The sequence of stored tree nodes from first to last.
    private var nodes : UtileSequence<TreeNodeRef,TreeNodeRef> {
      let first = prlcFirstTreeNode(self.store!)
      let step = {
        (treeNode : TreeNodeRef) in
        prlcNextTreeNode(self.store!, treeNode)
      }
      let data = {
        (treeNode : TreeNodeRef) in
        treeNode
      }
      return UtileSequence(first:first, step:step, data: data)
    }

    /// The sequence of parsed <include> nodes.
    /// includes.count <= inputs.count
    private var includes : UtileSequence<TreeNodeRef,TreeNodeRef>{
      return root!.children(where: { $0.type == PRLC_INCLUDE }) { $0 }
    }

    /// The sequence of parsed <cnf_annotated> nodes.
    /// cnfs.count <= inputs.count
    // private 
    var cnfs : UtileSequence<TreeNodeRef,TreeNodeRef>{
      return root!.children(where: { $0.type == PRLC_CNF }) { $0 }
    }

    /// The sequence of parsed <fof_annotated> nodes.
    /// fofs.count <= inputs.count
    private var fofs : UtileSequence<TreeNodeRef,TreeNodeRef>{
      return root!.children(where: { $0.type == PRLC_FOF }) { $0 }
    }
    
    func nameRoleClauseTriples<N:Node>(predicate:(String,Tptp.Role) -> Bool = { _,_ in true }) 
    -> [(String,Tptp.Role,N)] 
    where N:SymbolStringTyped {
        return self.cnfs.flatMap {
            guard let name = $0.symbol,
            let child = $0.child, 
            let string = child.symbol,
            let role = Tptp.Role(rawValue:string),
            let cnf = child.sibling else {
                let symbol = $0.symbol ?? "n/a"
                Syslog.error { "Invalid cnf \(symbol) in \(self.path)"}
                assert(false,"Invalid cnf in \(symbol) in \(self.path)")
                return nil
            }
            guard predicate(name,role) else {
                // name and role did not pass the test
                return nil
            }
            return (name,role,N(tree:cnf))
        }
    }
    
    func includeSelectionURLTriples(url:URL) -> [(String,[String],URL)] {
      return self.includes.flatMap {
        guard let name = $0.symbol,
        let axiomURL = URL(fileURLwithAxiom:name,problemURL:url) else {
          let symbol = $0.symbol ?? "'n/a'"
          Syslog.error { "Include file \(symbol) was not found."}
          assert(false, "Include file \(symbol) was not found.")
          return nil
        }
        let selection = $0.children.flatMap {
          $0.symbol
        }
        return (name,selection,axiomURL)
      }
    }
  }
}