import Core
import HTTP
import Driver
import Transport
import S3SignerAWS

@_exported import enum S3SignerAWS.Region

struct S3 {
    let s3Signer: S3SignerAWS
    let bucket: String
    let isVirtualHosted: Bool
    
    public init(
        accessKey: String,
        secretKey: String,
        region: Region,
        bucket: String,
        isBucketVirtualHosted: Bool = false
    ) {
        s3Signer = S3SignerAWS(
            accessKey: accessKey,
            secretKey: secretKey,
            region: region
        )
        
        self.bucket = bucket
        self.isVirtualHosted = isBucketVirtualHosted
    }

    public func upload(bytes: Bytes, path: String, access: AccessControlList) throws {
    }

    public func get(path: String) throws -> Response {
        let url = generateURL(for: path)
        
        let headers = try s3Signer.authHeaderV4(
            httpMethod: .get,
            urlString: url,
            headers: [:],
            payload: .none
        ).vaporHeaders
        
        return try BasicClient.get(url, headers: headers)
    }
    
    public func exist(file: String) {

    }

    public func delete(file: String) {

    }
}

extension S3 {
    func generateURL(for path: String) -> String {
        var url: String
        
        if isVirtualHosted {
            url = "https://\(bucket).s3.amazonaws.com/"
        } else {
            url = "https://s3.amazonaws.com/\(bucket)/"
        }
        
        return url + path
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
