import CTptpParsing

extension Tptp {
  final class File {

    private var store : StoreRef?
    /// The root of the parsed <TPTP_file>
    /// <TPTP_file> ::= <TPTP_input>*
    private(set) var root : TreeNodeRef?

    init?(path:FilePath) {
      Syslog.info { path }
      guard let size = path.fileSize, size > 0 else {
        return nil;
      }
      let code = prlcParsePath(path, &store, &root)
      guard code == 0 && self.store != nil && self.root != nil else {
        return nil
      }
    }

    init?(string:String, type: Tptp.SymbolType) {
      Syslog.info { string }


      let code : Int32

      switch type {
        case .variable:
        code = prlcParseString(string, &store, &root, PRLC_VARIABLE)
        case .function:
        code = prlcParseString(string, &store, &root, PRLC_FUNCTION)
        case .predicate:
        code = prlcParseString(string, &store, &root, PRLC_PREDICATE)
        case .cnf:
        code = prlcParseString(string, &store, &root, PRLC_CNF)
        case .fof:
        code = prlcParseString(string, &store, &root, PRLC_FOF)
        default:
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
    let t : N = N(tree:self.root!)
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
  private var cnfs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_CNF }) { $0 }
  }

  /// The sequence of parsed <fof_annotated> nodes.
  /// fofs.count <= inputs.count
  private var fofs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_FOF }) { $0 }
  }
}
