// swift-tools-version:5.5
import PackageDescription

let package = Package(
 name: "Core",
 platforms: [.macOS(.v10_15), .iOS(.v13)],
 products: [
  .library(name: "Core", targets: ["Core"]),
  .library(name: "Extensions", targets: ["Extensions"]),
  .library(name: "Components", targets: ["Components"]),
  .library(name: "Utilities", targets: ["Utilities"])
 ],
 targets: [
  .target(name: "Core"),
  .target(name: "Extensions", dependencies: ["Core"]),
  .target(name: "Components"),
  .target(name: "Utilities"),
  .testTarget(name: "CoreTests", dependencies: ["Core"]),
  .testTarget(name: "ExtensionsTests", dependencies: ["Extensions"])
 ]
)

// add OpenCombine for framewords that depend on Combine functionality
package.dependencies.append(
 .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0")
)
for target in package.targets {
 if target.name == "Core" {
  target.dependencies += [
   .product(
    name: "OpenCombine",
    package: "OpenCombine",
    condition: .when(platforms: [.wasi, .windows, .linux])
   )
  ]
  break
 }
}
