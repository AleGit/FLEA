import CTptpParsing

typealias StoreRef = UnsafeMutablePointer<prlc_store>



class TptpFile {
  private(set) var store : StoreRef?
  private(set) var root : TreeNodeRef?

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
