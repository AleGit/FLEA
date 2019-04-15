// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name:"FLEA",
	dependencies: [
		.package(url:"https://github.com/AleGit/CTptpParsing.git", from: "1.0.0" ),
		.package(url:"https://github.com/AleGit/CYices.git", from: "1.0.0" ),
		.package(url:"https://github.com/AleGit/CZ3Api.git", from: "1.0.0" )
	],
	targets: [
        .target(
            name: "FLEA"),
		.target(
			name: "FLEARunner", dependencies: ["FLEA"]
		),
        .testTarget(
            name: "FLEATests",
            dependencies: ["FLEA"]),
    ]
)
