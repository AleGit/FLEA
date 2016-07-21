import XCTest

@testable import FLEA

private typealias Node = SmartNode

public class WeakCollectionTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (WeakCollectionTests) -> () throws -> Void)]  {
    return [
      ("testWeakStringCollection", testWeakStringCollection)
    ]
  }

  func testWeakStringCollection() {
    // create a set with weak references
    var collection = WeakCollection<Stringly>()

    var s : Stringly? = "s"
    var t : Stringly? = "t"
    var x : Stringly? = "s"      // a reference to s

    XCTAssertEqual(s, x)        // s and x are equal
    XCTAssertFalse(s! === x!)   // but distinct instances

    // the set is empty
    XCTAssertEqual(collection.count, 0)

    // add three objects to the set
     s = collection.insert(newElement:s!)
     t = collection.insert(newElement:t!)
     x = collection.insert(newElement:x!)

    // just two objects are in the set
    XCTAssertEqual(collection.count, 2)

    XCTAssertEqual(s, x)        // s and x are equal
    XCTAssertTrue(s! === x!)    // and the same

    s = nil // discard reference to 's'
    t = nil // discard reference to 't'
    XCTAssertEqual(collection.count, 1)

    x = nil // discard last reference to 's'
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
