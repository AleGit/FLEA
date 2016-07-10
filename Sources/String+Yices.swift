import CYices

public extension String {

    /// Creates a String representation of a yices type
    public init?(tau: type_t, width:UInt32, height:UInt32, offset:UInt32) {
        guard let cstring = yices_type_to_string(tau, width, height, offset) else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        guard let string = String(validatingUTF8:cstring) else { return nil }
        self = string
    }

    /// Creates a String representation of a yices type
    public init?(tau: type_t) {
        self.init(tau: tau, width:UInt32.max, height:0, offset: 0)
    }

    /// Creates a String representation of a yices term
    public init?(term: term_t, width:UInt32, height:UInt32, offset:UInt32) {
        guard let cstring = yices_term_to_string(term, width, height, offset) else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }

        guard let string = String(validatingUTF8:cstring) else { return nil }
        self = string
    }

    /// Creates a String representation of a yices term
    public init?(term: term_t) {
        self.init(term: term, width:UInt32.max, height:0, offset: 0)
    }

    /// Creates a String representaion of yices model
    public init?(model: OpaquePointer, width:UInt32, height:UInt32, offset:UInt32) {
        guard let cstring = yices_model_to_string(model, width, height, offset) else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        guard let string = String(validatingUTF8:cstring) else { return nil }
        self = string
    }

    /// Creates a String representaion of yices model
    public init?(model: OpaquePointer) {
        self.init(model:model, width:UInt32.max, height:0, offset:0)
    }
}
