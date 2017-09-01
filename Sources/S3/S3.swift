import Core
import HTTP
import Transport
import AWSSignatureV4
import Vapor

@_exported import enum AWSSignatureV4.AWSError
@_exported import enum AWSSignatureV4.AccessControlList

public struct S3 {
    public enum Error: Swift.Error {
        case unimplemented
        case invalidResponse(Status)
    }

    let signer: AWSSignatureV4
    public var host: String

    public init(
        host: String,
        accessKey: String,
        secretKey: String,
        region: Region
    ) {
        self.host = host
        signer = AWSSignatureV4(
            service: "s3",
            host: host,
            region: region,
            accessKey: accessKey,
            secretKey: secretKey
        )
    }

    public func upload(bytes: Bytes, path: String, access: AccessControlList, mimeType: String? = nil) throws {
        let url = generateURL(for: path)
        
        let headers: [String : String] = {
            guard let mimeType = mimeType else {
                return [:]
            }
            return ["Content-Type": mimeType]
        }()
        let signedHeaders = try signer.sign(
            payload: .bytes(bytes),
            method: .put,
            path: path,
            query: nil,
            headers: headers
            //TODO(Brett): headers & AccessControlList
        )

        let response = try EngineClient.factory.put(url, signedHeaders, Body.data(bytes))
        guard response.status == .ok else {
            guard let bytes = response.body.bytes else {
                throw Error.invalidResponse(response.status)
            }

            throw try ErrorParser.parse(bytes)
        }
    }

    public func get(path: String) throws -> Bytes {
        let url = generateURL(for: path)
        let headers = try signer.sign(path: path)

        let response = try EngineClient.factory.get(url, headers)
        guard response.status == .ok else {
            guard let bytes = response.body.bytes else {
                throw Error.invalidResponse(response.status)
            }

            throw try ErrorParser.parse(bytes)
        }

        guard let bytes = response.body.bytes else {
            throw Error.invalidResponse(.internalServerError)
        }

        return bytes
    }

    public func delete(file: String) throws {
        throw Error.unimplemented
    }
}

extension S3 {
    func generateURL(for path: String) -> String {
        //FIXME(Brett):
        return "https://\(host)\(path)"
    }
}

extension Dictionary where Key: CustomStringConvertible, Value: CustomStringConvertible {
    var vaporHeaders: [HeaderKey: String] {
        var result: [HeaderKey: String] = [:]
        self.forEach {
            result.updateValue($0.value.description, forKey: HeaderKey($0.key.description))
        }

        return result
    }
}
