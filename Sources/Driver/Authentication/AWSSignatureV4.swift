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
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    let service: String
    let host: String
    let region: String
    let accessKey: String
    let secretKey: String
    
    //used for unit tests
    var unitTestDate: Date?
    
    var amzDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YYYYMMdd'T'HHmmss'Z'"
        return dateFormatter.string(from: unitTestDate ?? Date())
    }

    //TODO(Brett): public init
    init(
        service: String,
        host: String,
        region: String,
        accessKey: String,
        secretKey: String
    ) {
        self.service = service
        self.host = host
        self.region = region
        self.accessKey = accessKey
        self.secretKey = secretKey
    }

    func getStringToSign(
        algorithm: String,
        date: String,
        scope: String,
        canonicalHash: String
    ) -> String {
        return "\(algorithm)\n\(date)\n\(scope)\n\(canonicalHash)"
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
        return "\(dateStamp())/\(self.region)/\(self.service)/aws4_request"
    }
    
    func getCanonicalRequest(method: Method, path: String, query: String = "") throws -> String {
        let path = try path.percentEncode(allowing: Byte.awsPathAllowed)
        let query = try query.percentEncode(allowing: Byte.awsQueryAllowed)
    
        var request: String = ""
        
        let headers = "host:\(host)\nx-amz-date:\(amzDate)\n"
        let signedHeaders = "host;x-amz-date"
        let payload: Payload = .none
        var payloadHash: String

        do {
            payloadHash = try payload.hashed()
            request = "\(method.rawValue)\n\(path)\n\(query)\n\(headers)\n\(signedHeaders)\n\(payloadHash)"
        } catch {

        }

        return request
    }

    func dateStamp() -> String {
        let date = unitTestDate ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        return dateFormatter.string(from: date)
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
        
        let authorizationHeader = "\(algorithm) Credential=\(accessKey)/\(credentialScope), SignedHeaders=host;x-amz-date, Signature=\(signature)"
        
        return [
            "X-Amz-Date": amzDate,
            "Authorization": authorizationHeader
        ]
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
