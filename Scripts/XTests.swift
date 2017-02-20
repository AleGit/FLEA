import XCTest

@testable import FLEA

public class DemoTests: FleaTestCase {
    static var allTests: [(String, (DemoTests) -> () throws -> Void)] {
        return [
            ("testAll", testAll),
        ]
    }

    func testAll() {
        print("*** run all demos ***")
        Demo.all()
        print("*** all demos done ***")
    }
}
