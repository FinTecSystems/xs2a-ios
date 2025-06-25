// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "XS2AiOS",
	defaultLocalization: "de",
	platforms: [
		.iOS(.v11)
	],
	products: [
		.library(
			name: "XS2AiOS",
			type: .dynamic,
			targets: ["XS2AiOS"]),
	],
	dependencies: [
		.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
		.package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", from: "5.1.1"),
		.package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
		.package(url: "https://github.com/soyersoyer/SwCrypt.git", from: "5.1.4"),
		.package(url: "https://github.com/mervick/aes-everywhere-swift.git", from: "1.2.0"),
	],
	targets: [
		.target(
			name: "XS2AiOS",
			dependencies: [
				"SwiftyJSON",
				"NVActivityIndicatorView",
				"KeychainAccess",
				"SwCrypt",
				.product(name: "AesEverywhere", package: "aes-everywhere-swift") 
			],
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
