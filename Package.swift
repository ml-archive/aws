import PackageDescription

let package = Package(
    name: "AWS",
    targets: [
        Target(name: "AWS", dependencies: ["EC2", "S3", "AWSSignatureV4"]),
        Target(name: "EC2", dependencies: ["AWSSignatureV4"]),
        Target(name: "AutoScaling", dependencies: ["AWSSignatureV4"]),
        Target(name: "S3", dependencies: ["AWSSignatureV4"]),
        Target(name: "VaporS3", dependencies: ["S3"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
    ]
)
