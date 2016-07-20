import XCTest

@testable import FLEA

private typealias Node = SmartNode

public class SmartNodeTests : XCTestCase {
  /// Collect all tests by hand for Linux.
  static var allTests : [(String, (SmartNodeTests) -> () throws -> Void)]  {
    return [
      ("testSmartNodeEqualityX", testSmartNodeEqualityX),
      ("testSmartNodeEqualityY", testSmartNodeEqualityY),
      ("testWeakEntry", testWeakEntry)
    ]
  }

  func testSmartNodeEqualityX() {

    let X = Node(variable:"X")
    let a = Node(constant:"a")
    let fX = Node(symbol:"f", nodes:[X])
    let fa = Node(symbol:"f", nodes:[a])

    let fX_a = fX * [Node(variable:"X"):Node(constant:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)
    let count = Node.allNodes.count
    XCTAssertEqual(count,4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")
  }

  func testSmartNodeEqualityY() {

    let X = Node(variable:"Y")
    let a = Node(constant:"a")
    let fX = Node(symbol:"f", nodes:[X])
    let fa = Node(symbol:"f", nodes:[a])

    let fX_a = fX * [Node(variable:"Y"):Node(constant:"a")]

    XCTAssertEqual(fX_a,fa)
    XCTAssertTrue(fX_a == fa)
    XCTAssertTrue(fX_a === fa)
    let count = Node.allNodes.count
    XCTAssertEqual(count, 4, "\(nok)  \(#function) \(count) ≠ 4 smart nodes accumulated.")

  }



  func testWeakEntry() {
    var collection = WeakCollection<TestClass>()

    var s : TestClass? = TestClass("s")
    var t : TestClass? = TestClass("t")
    var x : TestClass? = TestClass("s")

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
    x = nil
    XCTAssertEqual(collection.count, 1)



  }



}

class TestClass : Hashable {
  let name : String
  var hashValue : Int { return name.hashValue }

  init(_ name:String) {
    self.name = name
  }

  deinit {
    print("\(#function) \(self.name)")
  }

}



func ==(lhs:TestClass, rhs:TestClass) -> Bool {
  return lhs.name == rhs.name
}
