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


    print(root?.pointee.symbol.dynamicType)
    print(root?.pointee.sibling.dynamicType)
    print(root?.pointee.child.dynamicType)

    let seq = self.tptpSequence

    for ref in seq {
      print(ref, String(treeNode:ref))
    }

    let a = seq.flatMap { String(treeNode:$0) }
    let b = self.tptpSequence { String(treeNode:$0) }
    let c = b.flatMap { $0 }
    print("a:", a)
    print("b:", b)
    print("c:", c)

    if let child = root?.first(start:{$0?.pointee.child}, step:{$0?.pointee.sibling}) {

    print(String(treeNode:child))
    }

  }
}
