import PackageDescription

let package = Package(
    name: "AWS",
    targets: [
        Target(name: "AWS", dependencies: ["EC2", "S3", "Authentication"]),
        Target(name: "EC2", dependencies: ["Authentication"]),
        Target(name: "S3", dependencies: ["Authentication"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/crypto.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/engine.git", majorVersion: 1)
    ]
)
