import Core
import HTTP
import Driver
import Transport

public struct S3 {
    public enum Error: Swift.Error {
        case unimplemented
        case invalidResponse(Status, String?)
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

    public func upload(bytes: Bytes, path: String, access: AccessControlList) throws {
        let url = generateURL(for: path)
        let headers = try signer.sign(
            payload: .bytes(bytes),
            method: .put,
            path: path
            //TODO(Brett): headers & AccessControlList
        )
        
        let response = try BasicClient.put(url, headers: headers, body: Body.data(bytes))
        guard response.status == .ok else {
            throw Error.invalidResponse(response.status, response.body.bytes?.string)
        }
    }

    public func get(path: String) throws -> Bytes {
        let url = generateURL(for: path)
        let headers = try signer.sign(path: path)
        
        let response = try BasicClient.get(url, headers: headers)
        guard response.status == .ok else {
            throw Error.invalidResponse(response.status, response.body.bytes?.string)
        }
        
        guard let bytes = response.body.bytes else {
            throw Error.invalidResponse(
                .internalServerError,
                "Response from S3 did not contain a body."
            )
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
