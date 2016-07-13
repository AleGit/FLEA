import CTptpParsing

extension TptpFile {
  var symbolStoreSize : Int {
    return store!.pointee.symbols.size
  }

  var prefixStoreSize : Int {
    return store!.pointee.p_nodes.size
  }

  var treeStoreSize : Int {
    return store!.pointee.t_nodes.size
  }
}

extension TptpFile {
  private subscript(index:size_t) -> TreeNodeRef? {
    return prlcTreeNodeAtIndex(store, index)
  }

  func index(of treeNode : TreeNodeRef?) -> size_t? {
    guard let treeNode = treeNode else { return nil }
    guard let base = self[0] else { return nil }
    let distance = base.distance(to: treeNode)

    assert(distance < treeStoreSize)

    return distance
  }

  func index(of symbol : String) -> size_t? {

    guard let base = prlcFirstSymbol(store) else { return nil }
    guard let symb = prlcGetSymbol(store,symbol) else { return nil }

    let distance = base.distance(to:symb)

    assert (distance < symbolStoreSize)

    return distance
  }
}

extension TptpFile {

  private func descendant (ancestor:TreeNodeRef?, advance:(TreeNodeRef?)->TreeNodeRef?) -> TreeNodeRef? {

    guard let ancestor = ancestor else { return nil }

    assert(index(of:ancestor) < self.treeStoreSize)

    guard let result = advance(ancestor) else { return nil }

    assert(index(of:result) < self.treeStoreSize)

    return result
  }

  private var sibling : (TreeNodeRef?) -> TreeNodeRef? {
    return {
      [unowned self]
      (ancestor:TreeNodeRef?) -> TreeNodeRef? in
      self.descendant(ancestor:ancestor) { $0?.pointee.sibling }
    }
  }

  private var child : (TreeNodeRef?) -> TreeNodeRef? {
    return {
      [unowned self]
      (ancestor:TreeNodeRef?) -> TreeNodeRef? in
      self.descendant(ancestor:ancestor) { $0?.pointee.child }
    }
  }

  private var successor : (TreeNodeRef?) -> TreeNodeRef? {
    return {
      [unowned self]
      (node:TreeNodeRef?) -> TreeNodeRef? in

      guard let node = node,
      let index = self.index(of:node)
      else { return nil }

        return self[index+1] // nil if index+1 == treeNodeSize

      }
    }

    private func first(from node:TreeNodeRef?,
      step: (TreeNodeRef?) -> TreeNodeRef?,
      where predicate:(TreeNodeRef)->Bool) -> TreeNodeRef? {
      guard let start = node else { return nil }

      if predicate(start) { return start }

      return next(after:start, step:step, where: predicate)
    }

    private func next(after node:TreeNodeRef?,
      step:(TreeNodeRef?)->TreeNodeRef?,
      where predicate:(TreeNodeRef)->Bool) -> TreeNodeRef? {
      guard var input = node else { return nil }

      while let next = step(input) {
        if predicate(next) { return next }
        input = next
      }
      return nil
    }

    private var firstTptpInclude : TreeNodeRef? {
      return first(from:root?.pointee.child, step:sibling) {
        $0.pointee.type == PRLC_INCLUDE
      }
    }

    private func nextTptpInclude (after treeNode: TreeNodeRef?) -> TreeNodeRef? {
        return next(after:treeNode, step:sibling) {
          $0.pointee.type == PRLC_INCLUDE
        }
    }

    private func children<T>(of parent:TreeNodeRef?, data:(TreeNodeRef)->T) -> FleaSequence<TreeNodeRef,T> {
      return FleaSequence(first: self.child(parent), step:self.sibling, data: data)
    }
  }
