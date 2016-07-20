import XCTest

@testable import FLEA

private typealias Node = SmartNode

public class WeakCollectionTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (WeakCollectionTests) -> () throws -> Void)]  {
    return [
      // ("testSmartNodeEqualityX", testSmartNodeEqualityX),
      // ("testSmartNodeEqualityY", testSmartNodeEqualityY),
      // ("test_WeakEntry", test_WeakEntry)
    ]
  }

  func testWeakStringCollection() {
    var collection = WeakCollection<Stringly>()

    var s : Stringly? = "s"
    var t : Stringly? = "t"
    var x : Stringly? = "s"

    XCTAssertEqual(s,x)
    XCTAssertFalse(s! === x!)
    XCTAssertEqual(collection.count, 0)

     s = collection.insert(newElement:s!)
     t = collection.insert(newElement:t!)
     x = collection.insert(newElement:x!)
    XCTAssertEqual(collection.count, 2)

    XCTAssertEqual(s,x)
    XCTAssertTrue(s! === x!)

    s = nil
    t = nil
    XCTAssertEqual(collection.count, 1)
    x = nil
    XCTAssertEqual(collection.count, 0)
  }
}

private final class Stringly : Hashable, CustomStringConvertible {
  let string : String
  var hashValue : Int { return string.hashValue }

  init(_ string:String) {
    self.string = string
  }

  deinit {
    print("\(#function) \(self.string)")
  }

  var description : String {
    return string
  }
}



private func ==(lhs:Stringly, rhs:Stringly) -> Bool {
  return lhs.string == rhs.string
}

extension Stringly: StringLiteralConvertible {
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    typealias UnicodeScalarLiteralType = StringLiteralType

    convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init("\(value)")
    }

    convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(value)
    }

    convenience init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
