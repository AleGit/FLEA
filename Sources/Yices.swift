import CYices

struct Yices {
	/// Get yices version string
	static var versionString: String {
		return String(validatingUTF8:yices_version) ?? "n/a"
	}
}

extension Yices {
	/// Check if code represents error code, i.e. code < 0
    static func check(code: Int32, label: String) -> Bool {
        if code < 0 {
          Syslog.error { "\(label) \(code) \(errorString)" }
          return false
        }

        return true
    }

	/// Get yices error string
    static var errorString: String {
        let cstring = yices_error_string()
        guard cstring != nil else {
            return "yices_error_string() n/a"
        }

        guard let string = String(validatingUTF8: cstring!) else {
            return "yices_error_string() n/c"
        }

        return string
    }
}

extension Yices {
	static func setUp() {
		yices_init()
	}
	static func tearDown() {
		yices_exit()
	}
}

extension Yices {

	final class Context {
		fileprivate var context: OpaquePointer

		init() {
			context = yices_new_context(nil)
		}

		deinit {
			yices_free_context(context)
		}

		func insure<N: Node>(clause:N) -> Yices.Tuple
		where N:SymbolStringTyped {
			let triple = Yices.clause(clause)
			yices_assert_formula(context, triple.0)
			return triple
		}

		func insure(clause: term_t) -> Bool {
			yices_assert_formula(context, clause)
			return isSatisfiable

		}

		var isSatisfiable: Bool {
			switch yices_check_context(context, nil) {
				case STATUS_SAT:
				return true
				case STATUS_UNSAT:
				return false
				default:
				assert(false)
				return true
			}
		}

	}

	final class Model {
		private var model : OpaquePointer

		init?(context:Context) {
			guard let m = yices_get_model(context.context,1) else {
				return nil
			}
			model = m
		}
		deinit {
			yices_free_model(model)
		}

		func implies(t:term_t) -> Bool {
			return yices_formula_true_in_model(model, t) > 0
		}

	}
}
