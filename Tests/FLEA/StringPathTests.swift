import XCTest

@testable import FLEA

public class StringPathTests : XCTestCase {


  static var allTests : [(String, (StringPathTests) -> () throws -> Void)] {
    return [
    ("testStringBasics", testStringBasics),
    ("testStringIndices", testStringIndices),
    ("testStringRanges", testStringRanges),
    ("testStringPaths", testStringPaths)
    ]
  }

  let path = "//Pαth/To/NÖWHERE/"
  let components = ["","","Pαth","To","NÖWHERE",""]

  /// test basic string methods to demonstrate usage
  func testStringBasics() {
    XCTAssertEqual(components, path.components(separatedBy:"/"),nok)

    XCTAssertEqual(path.capitalized,"//Pαth/To/Nöwhere/",nok)
    XCTAssertEqual(path.uppercased(),"//PΑTH/TO/NÖWHERE/",nok)
    XCTAssertEqual(path.lowercased(),"//pαth/to/nöwhere/",nok)

    print("hash = \(path.hash), hashValue = \(path.hashValue)")

    XCTAssertFalse(path.isEmpty,nok)

    XCTAssertEqual(path.characters.count,18,nok)
    XCTAssertEqual(path.smallestEncoding,String.Encoding.utf16,nok)
    XCTAssertEqual(path.fastestEncoding,String.Encoding.utf16,nok)

    // print(String.availableStringEncodings)

    let a = "a/path/to/where/"
    let b = "a/path/zu/whom/"
    let c = b.commonPrefix(with:a)

    XCTAssertEqual(c,"a/path/")
    XCTAssertTrue(a.hasPrefix(c))
    XCTAssertTrue(b.hasPrefix(c))

  }

  func testStringIndices() {

        print(path.startIndex)
        print(path.endIndex)

  }

  func testStringRanges() {


  }


  func testStringPaths() {
    // /Users/Shared/TPTP/Problems/PUZ/PUZ024-1.p
    // /Users/Shared/TPTP/Problems/PUZ/PUZ024-1.p
    // tptpPathTo(file: Axioms/PUZ002-0.ax ) ->
    // /Users/Shared/TPTP/Axioms/PUZ002-0.ax

    let problem = "PUZ024-1"
    let axiom = "PUZ002-0"

    let ppath = problem.p ?? nok
    XCTAssertTrue(ppath.hasSuffix("/TPTP/Problems/PUZ/PUZ024-1.p"),nok)

    let apath = axiom.ax ?? nok
    XCTAssertTrue(apath.hasSuffix("/TPTP/Axioms/PUZ002-0.ax"),nok)

    XCTAssertEqual(ppath.pathTo(axiom:axiom) ?? nok ?? nok, apath, nok)
    XCTAssertEqual("Problems".pathTo(axiom:axiom) ?? nok, apath, nok)

    let cpre = ppath.commonPrefix(with:apath)
    print(cpre)
    XCTAssertTrue(cpre.hasSuffix("/TPTP/"),nok)

    if ppath != nok { print("\(ok) '\(problem)'.p -> '\(ppath)'") }
    if ppath != nok { print("\(ok) '\(axiom)'.ax -> '\(apath)'") }

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
