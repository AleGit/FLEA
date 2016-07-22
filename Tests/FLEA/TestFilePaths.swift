import XCTest

@testable import FLEA

public class FilePathTests : XCTestCase {
  static var allTests : [(String, (FilePathTests) -> () throws -> Void)] {
    return [
    ("testBasics", testBasics)
    ]
  }


  func testBasics() {
    // /Users/Shared/TPTP/Problems/PUZ/PUZ024-1.p
    // /Users/Shared/TPTP/Problems/PUZ/PUZ024-1.p
    // tptpPathTo(file: Axioms/PUZ002-0.ax ) ->
    // /Users/Shared/TPTP/Axioms/PUZ002-0.ax

    let problem = "PUZ024-1"
    let axiom = "PUZ002-0"

    let ppath = problem.p ?? nok
    let apath = ppath.pathTo(axiom:axiom) ?? nok
    let path = "Problems".pathTo(axiom:axiom) ?? nok

    print("Problems".presuffix(separator:"Problems"))

    print("\(problem) -> \(ppath)")
    print("\(axiom) -> \(apath)")

    print("\(axiom) -> \(path)")

    print(axiom.ax)

    var outputName = "Helo"
    var array = [String]()

    print(FilePath.tptpRoot?.completePath(
      into:&outputName,
      caseSensitive:false,
      matchesInto:&array
    ))
    print(outputName)
    print(array)


  }
}
