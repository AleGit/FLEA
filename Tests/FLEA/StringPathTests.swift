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
    let s = "//Path/To/NÖWHERE/"
    let cs = ["","","Path","To","NÖWHERE",""]

    XCTAssertEqual(cs, s.components(separatedBy:"/"),nok)

    XCTAssertEqual(s.capitalized,"//Path/To/Nöwhere/",nok)
    XCTAssertEqual(s.uppercased(),"//PATH/TO/NÖWHERE/",nok)
    XCTAssertEqual(s.lowercased(),"//path/to/nöwhere/",nok)

    print(s.startIndex)
    print(s.endIndex)
    print(s.hash)
    print(s.hashValue)

    print(s.isEmpty)

        print(s.characters)
    print(s.smallestEncoding)
print(s.fastestEncoding)

print(String.availableStringEncodings)

let a = "a/path/to/where/"
let b = "a/path/zu/whom/"

let c = b.commonPrefix(with:a)

XCTAssertEqual(c,"a/path/")
XCTAssertTrue(a.hasPrefix(c))

XCTAssertTrue(b.hasPrefix(c))


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
