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



    // guard var file = tmpfile() else {
    //   self.init(c:"failed")
    // }
    // defer { fclose(file) }





    self.init(c:"failed")
  }
}
