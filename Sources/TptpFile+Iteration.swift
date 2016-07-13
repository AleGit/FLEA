import CTptpParsing



extension TptpFile {

  // private func first(base node:TreeNodeRef?,
  //   start: (TreeNodeRef?) -> TreeNodeRef? = { $0 },
  //   step: (TreeNodeRef?) -> TreeNodeRef?,
  //   where predicate:(TreeNodeRef)->Bool) -> TreeNodeRef? {
  //     guard let start = start(node) else { return nil }
  //
  //     if predicate(start) { return start }
  //
  //     return next(after:start, step:step, where: predicate)
  //   }
  //
  //   private func next(after node:TreeNodeRef?,
  //     step:(TreeNodeRef?)->TreeNodeRef?,
  //     where predicate:(TreeNodeRef)->Bool) -> TreeNodeRef? {
  //       guard var input = node else { return nil }
  //
  //       while let next = step(input) {
  //         if predicate(next) { return next }
  //         input = next
  //       }
  //       return nil
  //     }

      private var firstTptpInclude : TreeNodeRef? {
        return root?.first(start: {$0?.pointee.child}, step:{$0?.pointee.sibling}) {
          $0.pointee.type == PRLC_INCLUDE
        }
      }

      private func nextTptpInclude (after node: TreeNodeRef?) -> TreeNodeRef? {
        return node?.next(step:{$0?.pointee.sibling}) {
          $0.pointee.type == PRLC_INCLUDE
        }
      }

      private func children<T>(of parent:TreeNodeRef?, data:(TreeNodeRef)->T) -> FleaSequence<TreeNodeRef,T> {
        return FleaSequence(first: parent?.pointee.child, step:{$0.pointee.sibling}, data: data)
      }
    }

extension TptpFile {
  func tptpSequence<T>(_ data:(TreeNodeRef)->T) -> FleaSequence<TreeNodeRef,T> {
    return children(of:root) { data($0) }
  }

  var tptpSequence : FleaSequence<TreeNodeRef,TreeNodeRef>{
    return tptpSequence { $0 }
  }
}
