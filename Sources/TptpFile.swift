import CTptpParsing

class TptpFile {
  private var store : UnsafeMutablePointer<prlc_store>?
  private var root : UnsafeMutablePointer<prlc_tree_node>?

  init?(path:FilePath) {
    let code = prlcParseFile(path, &store, &root)
    guard code == 0 else {
      if let store = store {
        prlcDestroyStore(store)
      }
      return nil
    }

  }

  deinit {
    print("\(#function)")
    if let store = store {
      prlcDestroyStore(store)
    }
  }
}
