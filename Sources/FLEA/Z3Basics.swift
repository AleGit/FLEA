import CZ3Api

struct Z3Basics {

    static var version: [UInt32] {
        // void Z3_API 	Z3_get_version (unsigned *major, unsigned *minor, unsigned *build_number, unsigned *revision_number)
        var major = UInt32()
        var minor = UInt32()
        var build = UInt32()
        var revision = UInt32()

        Z3_get_version(&major, &minor, &build, &revision)
        return [major, minor, build, revision]
    }

    /// Get Z3 Api version string

    static var versionString: String {
        return Z3Basics.version.map { "\($0)" }.joined(separator: ".")
    }
}
