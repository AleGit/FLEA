import XCTest
@testable import CTptpParsing

public class CTptpParsingApiTests: FleaTestCase {
    static var allTests: [(String, (CTptpParsingApiTests) -> () throws -> Void)] {
        return [
            ("testStore", testStore),
            ("testTypes", testTypes),
        ]
    }

    func testStore() {
        prlcParsingStore = prlcCreateStore(1_000_000)
        guard let store = prlcParsingStore else {
            print("Error: creation of store failed.", "\(nok)")
            return
        }
        defer {
            prlcDestroyStore(store)
        }
        XCTAssertEqual(42, store.pointee.symbols.size, "\(nok)")
        XCTAssertEqual(20, store.pointee.p_nodes.size, "\(nok)")
        XCTAssertEqual(0, store.pointee.t_nodes.size, "\(nok)")

        XCTAssertEqual(333_333, store.pointee.symbols.capacity, "\(nok)")
        XCTAssertEqual(1_000_000, store.pointee.p_nodes.capacity, "\(nok)")
        XCTAssertEqual(333_333, store.pointee.t_nodes.capacity, "\(nok)")
    }

    func testTypes() {
        XCTAssertEqual(
            "\n ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>"
            , "\n \(type(of: prlcParsingStore))", "1 \(nok)")
        XCTAssertEqual(
            "\n ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_tree_node>>"
            , "\n \(type(of: prlcParsingRoot))", "2 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>, ImplicitlyUnwrappedOptional<UnsafeMutablePointer<Optional<UnsafeMutablePointer<prlc_store>>>>, ImplicitlyUnwrappedOptional<UnsafeMutablePointer<Optional<UnsafeMutablePointer<prlc_tree_node>>>>) -> Int32"
            , "\n \(type(of: prlcParsePath))", "3 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>) -> ()"
            , "\n \(type(of: prlcDestroyStore))", "4 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
            , "\n \(type(of: prlcStoreSymbol))", "5 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
            , "\n \(type(of: prlcGetSymbol))", "6 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
            , "\n \(type(of: prlcGetSymbol))", "7 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>) -> ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>"
            , "\n \(type(of: prlcGetSymbol))", "8 \(nok)")

        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_store>>, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>) -> ImplicitlyUnwrappedOptional<UnsafeMutablePointer<prlc_tree_node>>"
            , "\n \(type(of: prlcStoreNodeFile))", "9 \(nok)")
    }
}
