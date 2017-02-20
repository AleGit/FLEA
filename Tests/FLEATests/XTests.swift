import XCTest

@testable import FLEA

public class XTests: FleaTestCase {
    static var allTests: [(String, (XTests) -> () throws -> Void)] {
        return [
            ("testDemoDemo", testDemoDemo),
            ("testDemoProblem", testDemoProblem),
            ("testDemoProblemSimple", testDemoProblemSimple),
        ]
    }

    func testDemoDemo() {
        XCTAssertNil(Demo.demo())
    }

    func testDemoProblem() {
        Demo.show = false
        XCTAssertEqual(12, Demo.Problem.parseCnf(), nok)
        XCTAssertEqual(14, Demo.Problem.parseFof(), nok)
        XCTAssertEqual(0, Demo.Problem.broken(), nok)

        // too expensive in debug mode
        // XCTAssertEqual(12,Demo.Problem.simpleNode(show:false),nok)
        // XCTAssertEqual(12,Demo.Problem.sharingNode(show:false),nok)
        // XCTAssertEqual(12,Demo.Problem.smartNode(show:false),nok)
        // XCTAssertEqual(12,Demo.Problem.kinNode(show:false),nok)
    }

    func testDemoProblemSimple() {
        let f = Demo.Problem.simpleNode

        print("utileMeasure 'Demo.Problem.simpleNode'")
        let (result, runtime) = FLEA.utileMeasure(f:f)
        XCTAssertTrue(result > 0, nok)
        print("RUNTIME OF 'Demo.Problem.simpleNode'", runtime)

    }
}
