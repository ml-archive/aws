// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "AWS",
    products: [
        .library(name: "AWS", targets: ["AWS"]),
        .library(name: "VaporS3", targets: ["VaporS3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "2.2.0"),
        .package(url: "https://github.com/drmohundro/SWXMLHash", from: "4.1.1"),
    ],
    targets: [
        .target(name: "AWS", dependencies: ["AutoScaling", "EC2", "S3"]),
        .target(name: "AutoScaling", dependencies: ["AWSSignatureV4", "SWXMLHash"]),
        .target(name: "AWSSignatureV4", dependencies: ["Vapor"]),
        .target(name: "EC2", dependencies: ["AWSSignatureV4"]),
        .target(name: "S3", dependencies: ["AWSSignatureV4"]),
        .target(name: "VaporS3", dependencies: ["S3"]),
        .testTarget(name: "AWSTests", dependencies: ["AWS"]),
    ]
)
