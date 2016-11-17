import PackageDescription

let package = Package(
        name: "AWS",
        targets: [
                Target(name: "AWS"),
                Target(name: "EC2", dependencies: ["AWS"]),
                Target(name: "S3", dependencies: ["AWS"])
        ],
        dependencies: [
                .Package(url: "https://github.com/vapor/crypto.git", majorVersion: 1),
        ]
        )