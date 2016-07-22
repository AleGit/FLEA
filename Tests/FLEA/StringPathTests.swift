import XCTest

@testable import FLEA

public class StringPathTests : XCTestCase {
  static var allTests : [(String, (StringPathTests) -> () throws -> Void)] {
    return [
    ("testBasics", testBasics),
    ("testStrings", testStrings)
    ]
  }

  func testStrings() {
    let s = "//path/to/nowhere/"
    let cs = s.components(separatedBy:"/")
    XCTAssertEqual(cs,["","","path","to","nowhere",""])

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

    print(ppath.problemsPrefix)
    print(apath.problemsPrefix)

    print("\(problem) -> \(ppath)")
    print("\(axiom) -> \(apath)")

    print("\(axiom) -> \(path)")

    print(axiom.ax)

    #if os(OSX)

    var outputName = "Helo"
    var array = [String]()


    print(FilePath.tptpRoot?.completePath(
      into:&outputName,
      caseSensitive:false,
      matchesInto:&array
    ))
    print(outputName)
    print(array)
    #endif


  }
}
