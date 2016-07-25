import XCTest

@testable import FLEA

public class ConfigTests : XCTestCase {
  static var allTests : [(String, (ConfigTests) -> () throws -> Void)] {
    return [
    ("testFilePath", testFilePath)
    ]
  }

  func testFilePath() {
    print(Config.filePath)
  }
}
