import XCTest
@testable import CYices
//
class CYicesApiTests: FleaTestCase {
    static var allTests: [(String, (CYicesApiTests) -> () throws -> Void)] {
        return [
            ("testTypes", testTypes),
            ("testBasics", testBasics),
        ]
    }

    func testTypes() {

        XCTAssertEqual(
            "() -> ()",
            "\(type(of: yices_init))")

        XCTAssertEqual(
            "() -> ()",
            "\(type(of: yices_exit))")

        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<OpaquePointer>) -> ImplicitlyUnwrappedOptional<OpaquePointer>",
            "\n \(type(of: yices_new_context))", "3 \(nok)")
        XCTAssertEqual(
            "\n (ImplicitlyUnwrappedOptional<OpaquePointer>) -> ()",
            "\n \(type(of: yices_free_context))", "4 \(nok)")

        XCTAssertEqual(
            "() -> Int32",
            "\(type(of: yices_bool_type))")
        XCTAssertEqual(
            "\n (Int32) -> Int32",
            "\n \(type(of: yices_new_uninterpreted_term))", "6 \(nok)")
        XCTAssertEqual(
            "(Int32, ImplicitlyUnwrappedOptional<UnsafePointer<Int8>>) -> Int32",
            "\(type(of: yices_set_term_name))")
        XCTAssertEqual(
            "(UInt32, ImplicitlyUnwrappedOptional<UnsafePointer<Int32>>, Int32) -> Int32",
            "\(type(of: yices_function_type))")
        XCTAssertEqual(
            "(Int32, UInt32, ImplicitlyUnwrappedOptional<UnsafePointer<Int32>>) -> Int32",
            "\(type(of: yices_application))")
    }

    private func status(context: OpaquePointer, term: term_t,
                        expected: smt_status = STATUS_SAT, line: Int = #line) {

        guard let string = String(term: term) else { return }

        yices_assert_formula(context, term)

        let st = yices_check_context(context, nil)

        print("\(line): assert(\(string)) -> \(st.rawValue) expected=\(expected.rawValue)")

        XCTAssertEqual(expected, st, "\(nok) \(line) assert(\(string))")

        switch st {
        case STATUS_SAT:
            print("Satisfiable", expected == st ? ok : nok)

            // build the model and print it
            guard let mdl = yices_get_model(context, 1) else { return }
            defer { yices_free_model(mdl) }

            guard let model_string = String(model: mdl) else { return }
            print(model_string)
            break

        case STATUS_UNSAT:
            print("Unsatisfiable", expected == st ? ok : nok)
            break
        case STATUS_UNKNOWN:
            print("Status is unknown")
            break
        case STATUS_IDLE:
            fallthrough
        case STATUS_SEARCHING:
            fallthrough
        case STATUS_INTERRUPTED:
            fallthrough
        case STATUS_ERROR:
            fallthrough
        default:
            // these codes should not be returned
            print("Bug: unexpected status returned")
            break
        }
    }

    /// Constructs three clauses:
    /// - a tautology
    /// - a positive literal clause `p(f(a,b),a,b)`
    /// - a negative literal clause
    /// and checks satisfiability.
    func testBasics() {
        yices_init()
        defer { yices_exit() }

        guard let context = yices_new_context(nil) else { return }
        defer { yices_free_context(context) }

        let bool_tau = yices_bool_type()
        let free_tau = yices_int_type()

        // constant 'a'
        let a = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(a, "a")

        // constant 'b'
        let b = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(b, "b")

        // tpye '(free,free)->free'
        let f_domain = [type_t](repeating: free_tau, count: 2)
        let f_tau = yices_function_type(UInt32(f_domain.count), f_domain, free_tau)
        let f = yices_new_uninterpreted_term(f_tau)
        yices_set_term_name(f, "f")

        // function 'f(a,b)'
        var args = [a, b]
        let fab = yices_application(f, UInt32(args.count), args)

        // type '(free,free,free)->bool'
        let p_domain = [free_tau, free_tau, free_tau]
        let p_tau = yices_function_type(UInt32(p_domain.count), p_domain, bool_tau)
        let p = yices_new_uninterpreted_term(p_tau)
        yices_set_term_name(p, "p")

        // predicate 'p(fab,a,b)'
        args = [fab, a, b]
        let pfab = yices_application(p, UInt32(args.count), args)

        // 'NOT p(fab,a,b)'
        let npfab = yices_not(pfab)
        // 'p(fab,a,b) OR NOT p(fab,a,b)'
        let tautology = yices_or2(pfab, npfab)

        status(context: context, term: tautology)
        status(context: context, term: pfab)
        status(context: context, term: npfab, expected: STATUS_UNSAT)
    }
}
