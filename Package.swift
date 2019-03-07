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
		.package(url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/YvanMasterAll/SwiftValidators.git", from: "9.0.0"),
		.package(url: "https://github.com/stormpath/Turnstile.git", from: "1.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", from: "3.0.2"),
        .package(url: "https://github.com/YvanMasterAll/Turnstile-Perfect.git", from: "2.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-WebSockets.git", from: "3.1.0")
	],
	targets: [
		.target(name: "App", dependencies: [
			"PerfectRequestLogger", 	//请求日志
			"JSONConfig", 				//文件解析
			"PerfectHTTPServer",		//HTTP服务
			"PostgresStORM", 			//PostgreSQL ORM
			"PerfectPostgreSQL",		//PostgreSQL Provider
			"SwiftValidators",			//输入验证
			"Turnstile",				//请求认证
			"TurnstilePerfect",
			"PerfectMustache",			//模板引擎
			"PerfectWebSockets"			//通信协议
			]),
        .target(
            name: "Run",
            dependencies: ["App"]),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"])
	]
)