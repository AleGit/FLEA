import CTptpParsing



extension TptpFile {

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
    }

extension TptpFile {

  var inputs : FleaSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children { $0 }
  }

  var includes : FleaSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_INCLUDE }) { $0 }
  }

  var cnfs : FleaSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_CNF }) { $0 }
  }

  var fofs : FleaSequence<TreeNodeRef,TreeNodeRef>{
    return root!.children(where: { $0.type == PRLC_FOF }) { $0 }
  }
}
