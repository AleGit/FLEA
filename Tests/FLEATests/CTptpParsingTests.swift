import XCTest
@testable import CTptpParsing

public class CTptpParsingApiTests : FleaTestCase {
  static var allTests : [(String, (CTptpParsingApiTests) -> () throws -> Void)] {
    return [
      ("testStore", testStore),
      ("testTypes", testTypes)
    ]
  }


  func testStore() {
    prlcParsingStore = prlcCreateStore(1_000_000)
    guard let store = prlcParsingStore else {
      print("Error: creation of store failed.",nok)
      return
    }
    defer {
      prlcDestroyStore(store)
    }
    XCTAssertEqual(42,store.pointee.symbols.size,nok)
    XCTAssertEqual(20,store.pointee.p_nodes.size,nok)
    XCTAssertEqual(0,store.pointee.t_nodes.size,nok)

    XCTAssertEqual(333_333,store.pointee.symbols.capacity,nok)
    XCTAssertEqual(1_000_000,store.pointee.p_nodes.capacity,nok)
    XCTAssertEqual(333_333,store.pointee.t_nodes.capacity,nok)
  }

  func testTypes() {
    XCTAssertEqual(
      "ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>"
      ,"\(type(of:prlcParsingStore))",nok)
    XCTAssertEqual(
      "ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_tree_node>>"
      ,"\(type(of:prlcParsingRoot))",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>, ImplicitlyUnwrappedOptional<UnsafeMutablePointer<Optional<UnsafeMutablePointer<prlc_store>>>>, ImplicitlyUnwrappedOptional<UnsafeMutablePointer<Optional<UnsafeMutablePointer<prlc_tree_node>>>>)) -> Int32"
      ,"\(type(of:prlcParsePath))",nok)
    XCTAssertEqual(
      "(ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>) -> ()"
      ,"\(type(of:prlcDestroyStore))",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(type(of:prlcStoreSymbol))",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(type(of:prlcGetSymbol))",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(type(of:prlcGetSymbol))",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(type(of:prlcGetSymbol))",nok)

    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_tree_node>>"
      ,"\(type(of:prlcStoreNodeFile))",nok)


  }


}
