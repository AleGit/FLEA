import CTptpParsing



extension TptpFile {
  func printNodes() {
    guard let store = self.store else {
      print("No nodes available")
      return
    }
    var node = prlcFirstTreeNode(store)
    while node != nil {
      guard let string = String(treeNode:node) else {
        print("n/a")
        continue
      }
      print(string)
      node = prlcNextTreeNode(store, node)

    }
  }

  private func printThe(node : TreeNodeRef, prefix:String ) {
    if let string = String(treeNode:node) {
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

  func printInputs() {


print(root!.pointee.type.dynamicType)
    print(root!.pointee.symbol.dynamicType)
    print(root!.pointee.sibling.dynamicType)
    print(root!.pointee.child.dynamicType)

    print("inputs", self.inputs.map { $0.symbol! })
    print("includes", self.includes.map { $0.symbol! })
    print("cnfs", self.cnfs.map { $0.symbol! })
    print("fofs", self.fofs.map { $0.symbol! })

  }
}
