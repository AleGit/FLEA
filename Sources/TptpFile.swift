import CTptpParsing

class TptpFile {
  private var store : UnsafeMutablePointer<prlc_store>?
  private var root : UnsafeMutablePointer<prlc_tree_node>?

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
  func printNodes() {
    guard let store = self.store else {
      print("No nodes available")
      return
    }
    var node = prlcFirstTreeNode(store)
    while node != nil {
      guard let cstring = node?.pointee.symbol else {
        print("n/a")
        continue
      }
      let string = String(validatingUTF8:cstring) ?? "n/a"
      print(string)
      node = prlcNextTreeNode(store, node)

    }
  }

  private func printThe(node : UnsafeMutablePointer<prlc_tree_node>, prefix:String ) {
    if let cstring = node.pointee.symbol, let string = String(validatingUTF8:cstring) {
        print("\(prefix)'\(string)'")
    }
      else {
        print("'n/a'")
      }

      if let child = node.pointee.child {
        printThe(node:child, prefix:prefix + "  ")
      }

      if let sibling = node.pointee.sibling {
        printThe(node:sibling, prefix:prefix)
      }

    }

  func printIt() {
    guard let root = self.root else {
      print("no tree nodes to print")
      return
    }

    printThe(node:root,prefix:"")

  }
}
