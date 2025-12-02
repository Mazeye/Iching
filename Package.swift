// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Iching",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Iching",
            targets: ["Iching"]
        ),
        // 1. 新增：定义一个可执行产品，方便 swift run 调用
        .executable(
            name: "IchingDemo",
            targets: ["IchingDemo"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Iching"
        ),
        // 2. 新增：定义可执行目标，并依赖 "Iching" 库
        .executableTarget(
            name: "IchingDemo",
            dependencies: ["Iching"]
        ),
        .testTarget(
            name: "IchingTests",
            dependencies: ["Iching"]
        ),
    ]
)
