import PackageDescription

let package = Package(
    name: "AWS",
    targets: [
        Target(name: "AWS", dependencies: ["EC2", "S3", "AWSSignatureV4"]),
        Target(name: "EC2", dependencies: ["AWSSignatureV4"]),
        Target(name: "S3", dependencies: ["AWSSignatureV4"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/crypto.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/engine.git", majorVersion: 1)
    ]
)
