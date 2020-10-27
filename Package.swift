// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Blade",
    products: [
		.library(name: "Blade", targets: ["Blade"])
	],
    targets: [
        .target(name: "Blade"),
        .testTarget(name: "BladeTests", dependencies: ["Blade"]),
    ]
)
