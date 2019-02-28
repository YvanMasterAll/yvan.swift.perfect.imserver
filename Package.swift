// swift-tools-version:4.0
// Generated automatically by Perfect Assistant
// Date: 2019-02-21 04:02:35 +0000

import PackageDescription

let package = Package(
	name: "IMServer",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/iamjono/JSONConfig.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/SwiftORM/Postgres-StORM.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "App", dependencies: [
			"PerfectRequestLogger", 
			"JSONConfig", 
			"PerfectHTTPServer",
			"PostgresStORM", 
			"PerfectPostgreSQL"
			]),
        .target(
            name: "Run",
            dependencies: ["App"]),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"])
	]
)