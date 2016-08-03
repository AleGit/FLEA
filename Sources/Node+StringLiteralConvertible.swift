#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

extension Node where Symbol:Symbolable {

  init(unicodeScalarLiteral value: StringLiteralType) {
      self.init(stringLiteral: value)
  }

  init(extendedGraphemeClusterLiteral value: StringLiteralType) {
      self.init(stringLiteral: value)
  }




  /// We assume that we mainly want to create a single fol term.
  /// If value contains equality or logical symbols
  /// we generate a single fol formula.
  init(stringLiteral value: StringLiteralType) {
    // let fof = "fof(name,role,predicate(\(value))."
    self.init()

    let (string,type) = value.termLiteralType

    guard !string.isEmpty else {
      self = Self(c:"")
      return
    }

    guard let file = Tptp.File(string:string, type:type) else {
      self = Self(c:".❌ .")
      return
    }

    let a : Self? = file.ast()

    guard var ast = a else {
      self = Self(c:".❌ .❌ .")
      return
    }

    print(ast)


    switch type {
      // wrapped
      case .variable, .function:
        if let nodes = ast.nodes?.first?.nodes,
        nodes.count > 0, let term = nodes[1].nodes?.first?.nodes?.first {
          ast = term
        }

      case .predicate:
        if let nodes = ast.nodes?.first?.nodes,
        nodes.count > 0, let term = nodes[1].nodes?.first {
          ast = term
        }

      // not wrapped
      default:
        if let nodes = ast.nodes?.first?.nodes,
        nodes.count > 0 {
          ast = nodes[1]
        }
    }

    self = ast
  }
}
