import XCTest

@testable import FLEA

public class WeakSetTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (WeakSetTests) -> () throws -> Void)]  {
    return [
      ("testWeakStringSet", testWeakStringSet)
    ]
  }

  func testWeakStringSet() {
    // create a set with weak references
    var collection = WeakSet<Stringly>()

    var s : Stringly? = "s"
    var t : Stringly? = "t"
    var x : Stringly? = "s"      // a reference to s

    let temp : WeakSet<Stringly> = [s!,t!,x!,s!,t!,x!]
    XCTAssertEqual(temp.keyCount, 2)
    XCTAssertEqual(temp.totalCount, 2)
    XCTAssertEqual(temp.count, 2)
    XCTAssertEqual(temp.nilCount, 0)

    XCTAssertEqual(s, x)        // s and x are equal
    XCTAssertFalse(s! === x!)   // but distinct instances

    // the set is empty
    XCTAssertEqual(collection.count, 0)

    // add three objects to the set
    s = collection.insert(s!).memberAfterInsert
    t = collection.insert(t!).memberAfterInsert
    x = collection.insert(x!).memberAfterInsert

    XCTAssertEqual([t!,x!] as Set,Set(collection.map { $0 }),nok)

    // just two objects are in the set
    XCTAssertEqual(collection.count, 2)

    var array : [String]? = collection.map { $0.string }
    XCTAssertEqual(collection.count, 2)

    var barry : [String]? = collection.map { $0.string }
    XCTAssertEqual(collection.count, 2)

    XCTAssertEqual(array!,barry!)
    array = nil
    barry = nil

    XCTAssertEqual(s, x)        // s and x are equal
    XCTAssertTrue(s! === x!)    // and the same

    s = nil // discard reference to 's'
    t = nil // discard reference to 't'
    XCTAssertEqual(collection.count, 1)

    x = nil // discard last reference to 's'
    XCTAssertEqual(collection.count, 0)

    // temp is immutable, hence key count and total count are unchanged.
    XCTAssertEqual(temp.keyCount, 2)
    XCTAssertEqual(temp.totalCount, 2)
    // temp is immutable, nevertheless count and nil count has changed.
    XCTAssertEqual(temp.count, 0)
    XCTAssertEqual(temp.nilCount, 2)

    var copy = temp

    // copy stays the same as temp as long not mutating copy is executed.

    XCTAssertEqual(copy.keyCount, 2)
    XCTAssertEqual(copy.totalCount, 2)
    XCTAssertEqual(copy.count, 0)
    XCTAssertEqual(copy.nilCount, 2)

    copy.clean()

    XCTAssertEqual(copy.keyCount, 0)
    XCTAssertEqual(copy.totalCount, 0)
    XCTAssertEqual(copy.count, 0)
    XCTAssertEqual(copy.nilCount, 0)

    XCTAssertEqual(temp.nilCount, 2)
  }

  private final class Stringly : Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
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
    class final func ==(lhs:Stringly, rhs:Stringly) -> Bool {
      return lhs.string == rhs.string
    }
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
}