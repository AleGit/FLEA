import CTptpParsing

typealias TreeNodeRef = UnsafeMutablePointer<prlc_tree_node>
typealias PrefixNodeRef = UnsafeMutablePointer<prlc_prefix_node>

// MARK: - define C-structure protocols
protocol SymbolNodeProtocol {
    var symbol : UnsafePointer<Int8>! { get }
}

protocol TreeNodeProtocol : SymbolNodeProtocol {
  var type : PRLC_TREE_NODE_TYPE { get }
  var sibling : UnsafeMutablePointer<prlc_tree_node>! { get }
  var child : UnsafeMutablePointer<prlc_tree_node>! { get }
}

// MARK: - let C-structures conform to protocols

extension prlc_prefix_node : SymbolNodeProtocol { }
extension prlc_tree_node : TreeNodeProtocol { }

// MARK: -

extension UnsafeMutablePointer where Pointee : SymbolNodeProtocol {
  var symbol: String? {
    guard let cstring = self.pointee.symbol else { return nil }
    return String(validatingUTF8:cstring)
  }
}

extension UnsafeMutablePointer where Pointee : TreeNodeProtocol {
  var type : PRLC_TREE_NODE_TYPE {
    return self.pointee.type
  }

  var sibling : TreeNodeRef? {
    return self.pointee.sibling
  }

  var child : TreeNodeRef? {
    return self.pointee.child
  }
}

extension UnsafeMutablePointer where Pointee : TreeNodeProtocol {

  func first(
    start:(UnsafeMutablePointer?)->UnsafeMutablePointer? = { $0 },
    step:(UnsafeMutablePointer?)->UnsafeMutablePointer?,
    where predicate: (UnsafeMutablePointer) -> Bool = { _ in true }
  ) -> UnsafeMutablePointer? {
    guard let start = start(self) else { return nil }
    if predicate(start) { return start }
    return start.next(step:step, where:predicate)
  }

  func next(
    step:(UnsafeMutablePointer?)->UnsafeMutablePointer?,
    where predicate:(UnsafeMutablePointer)->Bool = { _ in true }
  ) -> UnsafeMutablePointer? {
    var input = self
    while let next = step(input) {
      if predicate(next) { return next}
      input = next
    }
    return nil
  }

  func children<T>(where predicate:(TreeNodeRef)->Bool = { _ in true}, data:(TreeNodeRef)->T) -> FleaSequence<TreeNodeRef,T> {
    return FleaSequence(first: self.child, step:{$0.pointee.sibling}, where:predicate, data: data)
  }

}
