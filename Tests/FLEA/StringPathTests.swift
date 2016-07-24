import XCTest

@testable import FLEA

public class StringPathTests : XCTestCase {


  static var allTests : [(String, (StringPathTests) -> () throws -> Void)] {
    return [
    ("testStringBasics", testBasics),
    ("testStringIndices", testIndices),
    ("testStringRanges", testRanges),
    ("testStringPaths", testPaths)
    ]
  }

  let ascii = "//Path/To/Nowhere/"
  let path = "//Pαth/To/NÖWHERE/"
  let components = ["","","Pαth","To","NÖWHERE",""]

  /// test basic string methods to demonstrate usage
  func testBasics() {
    XCTAssertEqual(components, path.components(separatedBy:"/"),nok)

    XCTAssertEqual(path.capitalized,"//Pαth/To/Nöwhere/",nok)
    XCTAssertEqual(path.uppercased(),"//PΑTH/TO/NÖWHERE/",nok)
    XCTAssertEqual(path.lowercased(),"//pαth/to/nöwhere/",nok)

    print("hash = \(path.hash), hashValue = \(path.hashValue)")

    XCTAssertFalse(path.isEmpty,nok)

    #if os(OSX)
    XCTAssertEqual(path.smallestEncoding,String.Encoding.ascii,nok)
    XCTAssertEqual(path.fastestEncoding,String.Encoding.utf16,nok)
    // #elseif os(Linux)
    // print(path.smallestEncoding, ascii.smalltesEncoding.dynamicType)
    // print(path.fastestEncoding, ascii.fastestEncoding.dynamicType)
    #endif

    #if os(OSX)
    XCTAssertEqual(ascii.smallestEncoding,String.Encoding.ascii,nok)
    XCTAssertEqual(ascii.fastestEncoding,String.Encoding.utf16,nok)
    // #elseif os(Linux)
    // print(ascii.smallestEncoding, ascii.smalltesEncoding.dynamicType)
    // print(ascii.fastestEncoding, ascii.fastestEncoding.dynamicType)
    #endif
    // print(String.availableStringEncodings)

    #if os(OSX)
    let c = path.commonPrefix(with:ascii)

    XCTAssertEqual(c,"//P")
    XCTAssertTrue(path.hasPrefix(c),nok)
    XCTAssertTrue(ascii.hasPrefix(c),nok)
    #endif

    XCTAssertEqual(
      Array(path.characters),["/", "/", "P",
      "α",
      "t", "h", "/", "T", "o", "/", "N",
      "Ö",
      "W", "H", "E", "R", "E", "/"],
      nok)

      XCTAssertEqual(
        Array(path.unicodeScalars), ["/", "/", "P",
        "\u{03B1}", // α
        "t", "h", "/", "T", "o", "/", "N",
        "\u{00D6}", //Ö
        "W", "H", "E", "R", "E", "/"],
      nok)

    XCTAssertEqual(
      Array(path.utf16),[47, 47, 80,
      945, // α
      116, 104, 47, 84, 111, 47, 78,
      214, // Ö
      87, 72, 69, 82, 69, 47],
      nok)

    XCTAssertEqual(
      Array(path.utf8),[47, 47, 80,
      206, 177, // α
      116, 104, 47, 84, 111, 47, 78,
      195, 150, // Ö
      87, 72, 69, 82, 69, 47],
      nok)


      print(Array(path.unicodeScalars).dynamicType)

      print(Array(path.characters).dynamicType)
      print(Array(path.utf16).dynamicType)
      print(Array(path.utf8).dynamicType)

  }

  func testLengths() {

    XCTAssertEqual(18, ascii.unicodeScalars.count,nok)
    XCTAssertEqual(18, ascii.characters.count,nok)
    XCTAssertEqual(18, ascii.utf16.count,nok)
    XCTAssertEqual(18, ascii.utf8.count,nok)

    XCTAssertEqual(18, path.unicodeScalars.count,nok)
    XCTAssertEqual(18, path.characters.count,nok)
    XCTAssertEqual(18, path.utf16.count,nok)
    XCTAssertEqual(20, path.utf8.count,nok)
  }

  func testIndices() {
    let cidx = path.characters.index(of:"Ö")!
    let uidx = cidx.samePosition(in: path.unicodeScalars)
    let utf8idx = cidx.samePosition(in: path.utf8)
    let utf16idx = cidx.samePosition(in: path.utf16)

    print(cidx)
    print(uidx)
    print(utf8idx)
    print(utf16idx)

    //XCTAssertEqual(cidx,uidx.samePosition(in: path.characters)!)
    //XCTAssertEqual(cidx,utf8idx.samePosition(in :path.characters)!)
    //XCTAssertEqual(cidx,utf16idx.samePosition(in :path.characters)!)


        let name = "Marie Curie"
        let firstSpace = name.characters.index(of: " ")!
        let firstName = String(name.characters.prefix(upTo: firstSpace))
        XCTAssertEqual("Marie", firstName,nok)
  }


  func testRanges() {
    let range = path.range(of:"To")!
    let first = path[path.startIndex..<range.lowerBound]
    XCTAssertEqual(first,"//Pαth/")
    let second = path[range.upperBound..<path.endIndex]
    XCTAssertEqual(second,"/NÖWHERE/")


    XCTAssertEqual(7,path.distance(from:path.startIndex, to: range.lowerBound),nok)
    XCTAssertEqual(9,path.distance(from:path.startIndex, to: range.upperBound),nok)
    XCTAssertEqual(-11,path.distance(from:path.endIndex, to: range.lowerBound),nok)
    XCTAssertEqual(-9,path.distance(from:path.endIndex, to: range.upperBound),nok)



  }


  func testPaths() {
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

    #if os(OSX)
    let cpre = ppath.commonPrefix(with:apath)
    XCTAssertTrue(cpre.hasSuffix("/TPTP/"),nok)
    #endif

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
