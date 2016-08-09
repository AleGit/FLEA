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

      #if os(OSX) // Swift 3 Preview 4 diverges
      if url.isFileURL {
        self.init(path:url.path)
      }
      else {
        return nil
      }
      #elseif os(Linux)
      if url.isFileURL, let path = url.path {
        self.init(path:path)
      }
      else {
        return nil
      }
      #endif
    }


    init?(string:String, type: Tptp.SymbolType) {
      Syslog.info { string }

      let code : Int32

      switch type {
        /// variables and (constant) are terms.
        case .function(_), .variable:
          code = prlcParseString(string, &store, &root, PRLC_FUNCTION)

        /// conjunctive normal form
        case .cnf:
          code = prlcParseString(string, &store, &root, PRLC_CNF)

        /// arbitrary first order formulas
        case .fof, .universal, .existential, .negation, .disjunction, .conjunction,
          .implication, .reverseimpl, .bicondition, .xor, .nand, .nor,
          .equation, .inequation, .predicate(_):
          code = prlcParseString(string, &store, &root, PRLC_FOF)

        /// include statements
        case .include:
          code = prlcParseString(string, &store, &root, PRLC_INCLUDE)

        /// the content of a file
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
  }
}

extension Tptp.File {

  func ast<N:Node where N.Symbol:Symbolable>() -> N? {
    guard let tree = self.root else { return nil }
    let t : N = N(tree:tree)
    return t
  }

  func ast<N:Node where N:SymbolTableUser,N.Symbol == N.Symbols.Symbol>() -> N? {
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
  var symbols : UtileSequence<CStringRef,String?> {
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

  /// The sequence of stored tree nodes.
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
}


/// MARK: - -- unused --
extension Tptp.File {

  /// The sequence of parsed <include> nodes.
  /// includes.count <= inputs.count
  private var includes : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_INCLUDE }) { $0 }
  }

  /// The sequence of parsed <cnf_annotated> nodes.
  /// cnfs.count <= inputs.count
  var cnfs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_CNF }) { $0 }
  }

  /// The sequence of parsed <fof_annotated> nodes.
  /// fofs.count <= inputs.count
  private var fofs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_FOF }) { $0 }
  }
}
