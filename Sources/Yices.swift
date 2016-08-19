import CYices

struct Yices {
	static var version : String {
		return String(validatingUTF8:yices_version) ?? "n/a"
	}
}

extension Yices {
    static func check(_ code : Int32, label: String) -> Bool {
        if code < 0 {
          Syslog.error { "\(label) \(code) \(errorString)" }
          return false
        }

        return true
    }

    static var errorString : String {
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
		private var context : OpaquePointer

		init() {
			context = yices_new_context(nil)
		}

		deinit {
			yices_free_context(context)
		}

		func assert<N:Node>(clause:N) -> Yices.Tuple 
		where N:SymbolStringTyped {
			let triple = Yices.clause(clause)


			yices_assert_formula(context,triple.0)
			return triple
		}

		var isSatisfiable : Bool {
			return yices_check_context(context,nil) == STATUS_SAT
		}

	}
}
