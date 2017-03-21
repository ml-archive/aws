import Core
import HTTP
import Transport
import AWSSignatureV4
import Vapor

@_exported import enum AWSSignatureV4.AWSError
@_exported import enum AWSSignatureV4.AccessControlList

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
}

//public struct S3 {
//    public enum Error: Swift.Error {
//        case unimplemented
//        case invalidResponse(Status)
//    }
//    
//    let signer: AWSSignatureV4
//    public var host: String
//    
//    public init(
//        host: String,
//        accessKey: String,
//        secretKey: String,
//        region: Region
//    ) {
//        self.host = host
//        signer = AWSSignatureV4(
//            service: "s3",
//            host: host,
//            region: region,
//            accessKey: accessKey,
//            secretKey: secretKey
//        )
//    }
//
//    public func upload(bytes: Bytes, path: String, access: AccessControlList) throws {
//        let url = generateURL(for: path)
//        let headers = try signer.sign(
//            payload: .bytes(bytes),
//            method: .put,
//            path: path
//            //TODO(Brett): headers & AccessControlList
//        )
//
//        let response = try EngineClient.put(url, headers, Body.data(bytes))
//        guard response.status == .ok else {
//            guard let bytes = response.body.bytes else {
//                throw Error.invalidResponse(response.status)
//            }
//            
//            throw try ErrorParser.parse(bytes)
//        }
//    }
//
//    public func get(path: String) throws -> Bytes {
//        let url = generateURL(for: path)
//        let headers = try signer.sign(path: path)
//        
//        let response = try EngineClient.get(url, headers)
//        guard response.status == .ok else {
//            guard let bytes = response.body.bytes else {
//                throw Error.invalidResponse(response.status)
//            }
//            
//            throw try ErrorParser.parse(bytes)
//        }
//        
//        guard let bytes = response.body.bytes else {
//            throw Error.invalidResponse(.internalServerError)
//        }
//        
//        return bytes
//    }
//
//    public func delete(file: String) throws {
//        throw Error.unimplemented
//    }
//}
//
//extension S3 {
//    func generateURL(for path: String) -> String {
//        //FIXME(Brett):
//        return "https://\(host)\(path)"
//    }
//}
//
//extension Dictionary where Key: CustomStringConvertible, Value: CustomStringConvertible {
//    var vaporHeaders: [HeaderKey: String] {
//        var result: [HeaderKey: String] = [:]
//        self.forEach {
//            result.updateValue($0.value.description, forKey: HeaderKey($0.key.description))
//        }
//        
//        return result
//    }
//}
