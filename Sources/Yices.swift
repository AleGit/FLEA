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
