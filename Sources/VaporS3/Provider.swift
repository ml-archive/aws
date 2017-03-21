import AWSSignatureV4
import Vapor
import S3

private let s3StorageKey = "s3-provider:s3"

public final class Provider: Vapor.Provider {
    let s3: S3

    public init(_ s3: S3) {
        self.s3 = s3
    }

    public convenience init(host: String, accessKey: String, secretKey: String, region: Region) {
        let s3 = S3(host: host, accessKey: accessKey, secretKey: secretKey, region: region)
        self.init(s3)
    }

    public convenience init(config: Config) throws {
        guard let s3Config = config["s3"] else { throw ConfigError.missingFile("s3") }
        guard let host = s3Config["host"]?.string else {
            throw ConfigError.missing(key: ["host"], file: "s3", desiredType: String.self)
        }
        guard let accessKey = s3Config["accessKey"]?.string else {
            throw ConfigError.missing(key: ["accessKey"], file: "s3", desiredType: String.self)
        }
        guard let secretKey = s3Config["secretKey"]?.string else {
            throw ConfigError.missing(key: ["secretKey"], file: "s3", desiredType: String.self)
        }
        guard let region = s3Config["region"]?.string.flatMap(Region.init) else {
            throw ConfigError.missing(key: ["region"], file: "s3", desiredType: Region.self)
        }
        self.init(host: host, accessKey: accessKey, secretKey: secretKey, region: region)
    }

    public func boot(_ drop: Droplet) throws {
        drop.storage[s3StorageKey] = s3
    }

    public func beforeRun(_ drop: Droplet) throws {}
}

extension Droplet {
    public func s3() throws -> S3 {
        guard let s3 = storage[s3StorageKey] as? S3 else { throw VaporS3Error.s3NotFound }
        return s3
    }
}
