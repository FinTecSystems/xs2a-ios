// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "XS2AiOS",
	defaultLocalization: "de",
	platforms: [
		.iOS(.v10)
	],
	products: [
		.library(
			name: "XS2AiOS",
			targets: ["XS2AiOS"]),
	],
	dependencies: [
		.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
		.package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", from: "5.1.1"),
		.package(name: "XS2AiOSNetService", url: "https://github.com/FinTecSystems/xs2a-ios-netservice.git", from: "1.0.7"),
		.package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
	],
	targets: [
		.target(
			name: "XS2AiOS",
			dependencies: ["SwiftyJSON", "NVActivityIndicatorView", "XS2AiOSNetService", "KeychainAccess"],
			resources: [
				.process("Resources")
			]
		),
		.testTarget(
			name: "XS2AiOSTests",
			dependencies: ["XS2AiOS"]),
	],
	swiftLanguageVersions: [SwiftVersion.v5]
)
