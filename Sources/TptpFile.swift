import CTptpParsing

typealias StoreRef = UnsafeMutablePointer<prlc_store>



class TptpFile {
  private var store : StoreRef?
  private var root : TreeNodeRef?

  init?(path:FilePath) {
    print("\(#function) '\(path)'")
    guard let size = path.fileSize where size > 0 else {
      return nil;
    }
    let code = prlcParseFile(path, &store, &root)
    guard code == 0 && self.store != nil && self.root != nil else {
      if let store = self.store {
        prlcDestroyStore(store)
      }
      return nil
    }
  }

  var path: FilePath {
    guard let cstring = root?.pointee.symbol else { return "n/a" }
    return String(validatingUTF8:cstring) ?? "n/a"
  }


  deinit {
    print("\(#function) '\(self.path)'")
    if let store = store {
      prlcDestroyStore(store)
    }
  }
}

extension TptpFile {

  var inputs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children { $0 }
  }

  var includes : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_INCLUDE }) { $0 }
  }

  var cnfs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_CNF }) { $0 }
  }

  var fofs : UtileSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_FOF }) { $0 }
  }

  var symbols : UtileSequence<CStringRef,String?> {
    let step = {
      (cstring : CStringRef) in
      prlcNextSymbol(self.store!,cstring)
    }
    let data = {
      (cstring : CStringRef) in
      String(validatingUTF8:cstring)
    }

    return UtileSequence(first:prlcFirstSymbol(store!), step:step, data:data)
  }
}

extension TptpFile {
  func printInputs() {
    Swift.print("* inputs  :", self.inputs.map { $0.symbol! })
    Swift.print("* includes:", self.includes.map { $0.symbol! })
    Swift.print("* cnfs    :", self.cnfs.map { $0.symbol! })
    Swift.print("* fofs    :", self.fofs.map { $0.symbol! })
    Swift.print("* symbols :", self.symbols.map { $0! })
  }
}
