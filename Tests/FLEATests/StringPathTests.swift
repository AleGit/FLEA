import XCTest

@testable import FLEA

public class StringPathTests: FleaTestCase {

    static var allTests: [(String, (StringPathTests) -> () throws -> Void)] {
        return [
            ("testStringBasics", testBasics),
            ("testStringIndices", testIndices),
            ("testStringIndices", testLengths),
            ("testStringRanges", testRanges),
            ("testStringPaths", testPaths),
            ("testTrimmingWhitespace", testTrimmingWhitespace),
        ]
    }

    let ascii = "//Path/To/Nowhere/"
    let path = "//Pαth/To/NÖWHERE/"
    let components = ["", "", "Pαth", "To", "NÖWHERE", ""]

    /// test basic string methods to demonstrate usage
    func testBasics() {
        XCTAssertEqual(components, path.components(separatedBy: "/"), nok)

        XCTAssertEqual(path.capitalized, "//Pαth/To/Nöwhere/", nok)
        XCTAssertEqual(path.uppercased(), "//PΑTH/TO/NÖWHERE/", nok)
        XCTAssertEqual(path.lowercased(), "//pαth/to/nöwhere/", nok)
        XCTAssertFalse(path.isEmpty, nok)

        #if os(OSX)
            print(path.smallestEncoding, String.Encoding.utf16, String.Encoding.ascii)
            XCTAssertEqual(path.fastestEncoding, String.Encoding.utf16, nok)
            // #elseif os(Linux)
            // print(path.smallestEncoding, ascii.smalltesEncoding.dynamicType)
            // print(path.fastestEncoding, ascii.fastestEncoding.dynamicType)
        #endif

        #if os(OSX)
            XCTAssertEqual(ascii.smallestEncoding, String.Encoding.ascii, nok)
            XCTAssertEqual(ascii.fastestEncoding, String.Encoding.utf16, nok)
            // #elseif os(Linux)
            // print(ascii.smallestEncoding, ascii.smalltesEncoding.dynamicType)
            // print(ascii.fastestEncoding, ascii.fastestEncoding.dynamicType)
        #endif
        // print(String.availableStringEncodings)

        #if os(OSX)
            let c = path.commonPrefix(with: ascii)

            XCTAssertEqual(c, "//P")
            XCTAssertTrue(path.hasPrefix(c), nok)
            XCTAssertTrue(ascii.hasPrefix(c), nok)
        #endif

        XCTAssertEqual(
            Array(path), [
                "/", "/", "P",
                "α", "t", "h", "/", "T", "o", "/", "N",
                "Ö", "W", "H", "E", "R", "E", "/",
            ],
            nok)

        XCTAssertEqual(
            Array(path.unicodeScalars), [
                "/", "/", "P", "\u{03B1}", // α
                "t", "h", "/", "T", "o", "/", "N", "\u{00D6}", // Ö
                "W", "H", "E", "R", "E", "/",
            ],
            nok)

        XCTAssertEqual(
            Array(path.utf16), [
                47, 47, 80, 945, // α
                116, 104, 47, 84, 111, 47, 78, 214, // Ö
                87, 72, 69, 82, 69, 47,
            ],
            nok)

        XCTAssertEqual(
            Array(path.utf8), [
                47, 47, 80, 206, 177, // α
                116, 104, 47, 84, 111, 47, 78, 195, 150, // Ö
                87, 72, 69, 82, 69, 47,
            ],
            nok)
    }

    func testLengths() {

        XCTAssertEqual(18, ascii.unicodeScalars.count, nok)
        XCTAssertEqual(18, ascii.count, nok)
        XCTAssertEqual(18, ascii.utf16.count, nok)
        XCTAssertEqual(18, ascii.utf8.count, nok)

        XCTAssertEqual(18, path.unicodeScalars.count, nok)
        XCTAssertEqual(18, path.count, nok)
        XCTAssertEqual(18, path.utf16.count, nok)
        XCTAssertEqual(20, path.utf8.count, nok)
    }

    func testIndices() {
        let cidx = path.index(of: "Ö")!
        let uidx = cidx.samePosition(in: path.unicodeScalars)
        let utf8idx = cidx.samePosition(in: path.utf8)
        let utf16idx = cidx.samePosition(in: path.utf16)

        print(cidx)
        print(uidx!)
        print(utf8idx!)
        print(utf16idx!)

        let name = "Marie Curie"
        let firstSpace = name.index(of: " ")!
        let firstName = String(name.prefix(upTo: firstSpace))
        XCTAssertEqual("Marie", firstName, nok)
    }

    func testRanges() {
        let range = path.range(of: "To")!
        let first = path[path.startIndex ..< range.lowerBound]
        XCTAssertEqual(first, "//Pαth/")
        let second = path[range.upperBound ..< path.endIndex]
        XCTAssertEqual(second, "/NÖWHERE/")

        XCTAssertEqual(7, path.distance(from: path.startIndex, to: range.lowerBound), nok)
        XCTAssertEqual(9, path.distance(from: path.startIndex, to: range.upperBound), nok)
        XCTAssertEqual(-11, path.distance(from: path.endIndex, to: range.lowerBound), nok)
        XCTAssertEqual(-9, path.distance(from: path.endIndex, to: range.upperBound), nok)
    }

    func testPaths() {
        // /Users/Shared/TPTP/Problems/PUZ/PUZ024-1.p
        // /Users/Shared/TPTP/Problems/PUZ/PUZ024-1.p
        // tptpPathTo(file: Axioms/PUZ002-0.ax ) ->
        // /Users/Shared/TPTP/Axioms/PUZ002-0.ax

        // let problem = "PUZ024-1"
        // let axiom = "PUZ002-0"
        //
        // guard let problemUrl = URL(fileURLWithProblem:problem) else {
        //   XCTFail("\(nok) no url for \(problem)")
        // }
        // XCTAssertTrue(problemUrl.path.hasSuffix("/TPTP/Problems/PUZ/PUZ024-1.p"), nok)
        //
        // let apath = axiom.ax ?? nok
        // XCTAssertTrue(apath.hasSuffix("/TPTP/Axioms/PUZ002-0.ax"), nok)
        //
        // XCTAssertEqual(problemUrl.pathTo(axiom:axiom) ?? nok ?? nok, apath, nok)
        // XCTAssertEqual("Problems".pathTo(axiom:axiom) ?? nok, apath, nok)
        //
        // #if os(OSX)
        // let cpre = ppath.commonPrefix(with:apath)
        // XCTAssertTrue(cpre.hasSuffix("/TPTP/"), nok)
        // #endif
        //
        // if ppath != nok { print("\(ok) '\(problem)'.p -> '\(ppath)'") }
        // if ppath != nok { print("\(ok) '\(axiom)'.ax -> '\(apath)'") }
        //
    }

    func testTrimmingWhitespace() {
        XCTAssertEqual("A Bc", "A Bc".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", " A Bc".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", " A Bc ".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", "A Bc ".trimmingWhitespace, nok)

        XCTAssertEqual("A Bc", "      A Bc".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", "   A Bc   ".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", "A Bc      ".trimmingWhitespace, nok)

        XCTAssertEqual("A Bc", "A Bc\n".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", " A Bc\n".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", " A Bc \n".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", "A Bc \n".trimmingWhitespace, nok)

        XCTAssertEqual("A Bc", "      A Bc\n".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", "   A Bc   \n".trimmingWhitespace, nok)
        XCTAssertEqual("A Bc", "A Bc      \n".trimmingWhitespace, nok)
    }
}
