import XCTest
@testable import CTptpParsing

public class CTptpParsingApiTests : XCTestCase {
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
      ,"\(prlcParsingStore.dynamicType)",nok)
    XCTAssertEqual(
      "ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_tree_node>>"
      ,"\(prlcParsingRoot.dynamicType)",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>, ImplicitlyUnwrappedOptional<UnsafeMutablePointer<Optional<UnsafeMutablePointer<prlc_store>>>>, ImplicitlyUnwrappedOptional<UnsafeMutablePointer<Optional<UnsafeMutablePointer<prlc_tree_node>>>>)) -> Int32"
      ,"\(prlcParsePath.dynamicType)",nok)
    XCTAssertEqual(
      "(ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>) -> ()"
      ,"\(prlcDestroyStore.dynamicType)",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(prlcStoreSymbol.dynamicType)",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(prlcGetSymbol.dynamicType)",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(prlcGetSymbol.dynamicType)",nok)
    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
      ,"\(prlcGetSymbol.dynamicType)",nok)

    XCTAssertEqual(
      "((ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>)) -> ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_tree_node>>"
      ,"\(prlcStoreNodeFile.dynamicType)",nok)


  }


}
