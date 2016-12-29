import Core
import Hash
import HMAC
import HTTP
import Essentials
import Foundation

public enum AccessControlList: String {
    case privateAccess = "private"
    case publicRead = "public-read"
    case publicReadWrite = "public-read-write"
    case awsExecRead = "aws-exec-read"
    case authenticatedRead = "authenticated-read"
    case bucketOwnerRead = "bucket-owner-read"
    case bucketOwnerFullControl = "bucket-owner-full-control"
}

public struct AWSSignatureV4 {
    public enum Method: String {
        case delete = "DELETE"
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    let service: String
    let host: String
    let region: String
    let accessKey: String
    let secretKey: String
    
    var unitTestDate: Date?
    
    var amzDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YYYYMMdd'T'HHmmss'Z'"
        return dateFormatter.string(from: unitTestDate ?? Date())
    }

    public init(
        service: String,
        host: String,
        region: Region,
        accessKey: String,
        secretKey: String
    ) {
        self.service = service
        self.host = host
        self.region = region.rawValue
        self.accessKey = accessKey
        self.secretKey = secretKey
    }

    func getStringToSign(
        algorithm: String,
        date: String,
        scope: String,
        canonicalHash: String
    ) -> String {
        return [
            algorithm,
            date,
            scope,
            canonicalHash
        ].joined(separator: "\n")
    }
    
    func getSignature(_ stringToSign: String) throws -> String {
        let dateHMAC = try HMAC.make(.sha256, dateStamp().bytes, key: "AWS4\(secretKey)".bytes)
        let regionHMAC = try HMAC.make(.sha256, region.bytes, key: dateHMAC)
        let serviceHMAC = try HMAC.make(.sha256, service.bytes, key: regionHMAC)
        let signingHMAC = try HMAC.make(.sha256, "aws4_request".bytes, key: serviceHMAC)

        let signature = try HMAC.make(.sha256, stringToSign.bytes, key: signingHMAC)
        return signature.hexString
    }

    func getCredentialScope() -> String {
        return [
            dateStamp(),
            region,
            service,
            "aws4_request"
        ].joined(separator: "/")
    }
    
    func getCanonicalRequest(
        payload: Payload,
        method: Method,
        path: String,
        query: String,
        headers: [String : String] = [:]
    ) throws -> String {
        let path = try path.percentEncode(allowing: Byte.awsPathAllowed)
        let query = try query.percentEncode(allowing: Byte.awsQueryAllowed)
        let payloadHash = try payload.hashed()
        
        var headers = headers
        generateHeadersToSign(headers: &headers, host: host, hash: payloadHash)
        
        let sortedHeaders = alphabetize(headers)
        let canonicalHeaders = createCanonicalHeaders(sortedHeaders)
        let headersToSign = sortedHeaders.map { $0.key.lowercased() }.joined(separator: ";")
        
        return [
            method.rawValue,
            path,
            query,
            canonicalHeaders,
            "",
            headersToSign,
            payloadHash
        ].joined(separator: "\n")
    }

    func dateStamp() -> String {
        let date = unitTestDate ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        return dateFormatter.string(from: date)
    }
}

extension AWSSignatureV4 {
    func generateHeadersToSign(
        headers: inout [String: String],
        host: String,
        hash: String
    ) {
        headers["host"] = host
        headers["X-Amz-Date"] = amzDate
        
        if hash != "UNSIGNED-PAYLOAD" {
            headers["x-amz-content-sha256"] = hash
        }
    }
    
    func alphabetize(_ dict: [String : String]) -> [(key: String, value: String)] {
        return dict.sorted(by: { $0.0.lowercased() < $1.0.lowercased() })
    }
    
    func createCanonicalHeaders(_ headers: [(key: String, value: String)]) -> String {
        return headers.map {
            "\($0.key.lowercased()):\($0.value)"
        }.joined(separator: "\n")
    }
    
    func signPayload(
        _ payload: Payload,
        mime: String?,
        headers: inout [HeaderKey : String]
    ) throws {
        /*let contentLength: Int
        
        switch payload {
        case .bytes(let bytes):
            contentLength = bytes.count
        default:
            contentLength = 0
        }
        
        headers["Content-Length"] = "\(contentLength)"
        if let mime = mime {
            headers["Content-Type"] = mime
        }
        
        headers["x-amz-content-sha256"] = try payload.hashed()*/
    }
}

extension AWSSignatureV4 {
    public func sign(
        payload: Payload = .none,
        method: Method = .get,
        path: String,
        query: String? = nil,
        headers: [String : String] = [:]
    ) throws -> [HeaderKey : String] {
        let algorithm = "AWS4-HMAC-SHA256"
        let credentialScope = getCredentialScope()
        
        let canonicalRequest = try getCanonicalRequest(
            payload: payload,
            method: method,
            path: path,
            query: query ?? ""
        )

        let canonicalHash = try Hash.make(.sha256, canonicalRequest).hexString
        
        let stringToSign = getStringToSign(
            algorithm: algorithm,
            date: amzDate,
            scope: credentialScope,
            canonicalHash: canonicalHash
        )
        
        let signature = try getSignature(stringToSign)
        
        let authorizationHeader = "\(algorithm) Credential=\(accessKey)/\(credentialScope), SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=\(signature)"
        
        return [
            "X-Amz-Date": amzDate,
            "x-amz-content-sha256": try payload.hashed(),
            "Authorization": authorizationHeader
        ]
    }
}
