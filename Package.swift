// swift-tools-version:4.0
// Generated automatically by Perfect Assistant
// Date: 2019-02-21 04:02:35 +0000
import PackageDescription

let package = Package(
	name: "IMServer",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Turnstile-PostgreSQL.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "IMServer", dependencies: ["PerfectRequestLogger", "PerfectTurnstilePostgreSQL"])
	]
)