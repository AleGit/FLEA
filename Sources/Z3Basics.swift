import CZ3Api

struct Z3Basics {
	/// Get Z3 Api version string

    static var versionString: String {
        // void Z3_API 	Z3_get_version (unsigned *major, unsigned *minor, unsigned *build_number, unsigned *revision_number)
		var major: UInt32 = 0
        var minor: UInt32 = 0
        var build: UInt32 = 0
        var revision: UInt32 = 0

        Z3_get_version(&major, &minor, &build, &revision)
        return "\(major).\(minor).\(build).\(revision)"
	}




}