import Core
import Crypto
import HTTP
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
    let contentType = "application/x-www-form-urlencoded; charset=utf-8"
    
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
        let dateHMAC = try HMAC(.sha256, dateStamp()).authenticate(key: "AWS4\(secretKey)")
        let regionHMAC = try HMAC(.sha256, region).authenticate(key: dateHMAC)
        let serviceHMAC = try HMAC(.sha256, service).authenticate(key: regionHMAC)
        let signingHMAC = try HMAC(.sha256, "aws4_request").authenticate(key: serviceHMAC)

        let signature = try HMAC(.sha256, stringToSign).authenticate(key: signingHMAC)
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
        payloadHash: String,
        method: Method,
        path: String,
        query: String,
        canonicalHeaders: String,
        signedHeaders: String
    ) throws -> String {
        let path = try path.percentEncode(allowing: Byte.awsPathAllowed)
        // Looks like this _isn't_ required? At least not for = and &, which is
        // all the AutoScaling.DescribeAutoScalingGroups API needed.
        // If this breaks for another API call then try to reintroduce
        // but remove both & and = from Byte.awsQueryAllowed
        //let query = try query.urlEncode(allowing: Byte.awsQueryAllowed)
        
        return [
            method.rawValue,
            path,
            query,
            canonicalHeaders,
            "",
            signedHeaders,
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
        headers["Content-Type"] = contentType

        /* This didn't appear to be necessary either. Keeping for a release in case in helps someone
         if hash != "UNSIGNED-PAYLOAD" {
            headers["x-amz-content-sha256"] = hash
        }*/
    }
    
    func alphabetize(_ dict: [String : String]) -> [(key: String, value: String)] {
        return dict.sorted(by: { $0.0.lowercased() < $1.0.lowercased() })
    }
    
    func createCanonicalHeaders(_ headers: [(key: String, value: String)]) -> String {
        return headers.map {
            "\($0.key.lowercased()):\($0.value)"
        }.joined(separator: "\n")
    }
    
    func createAuthorizationHeader(
        algorithm: String,
        credentialScope: String,
        signature: String,
        signedHeaders: String
    ) -> String {
        return "\(algorithm) Credential=\(accessKey)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
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
        let payloadHash = try payload.hashed()
        
        var headers = headers
        generateHeadersToSign(headers: &headers, host: host, hash: payloadHash)
        
        let sortedHeaders = alphabetize(headers)
        let signedHeaders = sortedHeaders.map { $0.key.lowercased() }.joined(separator: ";")
        //print("Signed Headers:\n\(signedHeaders)\n***\n")
        let canonicalHeaders = createCanonicalHeaders(sortedHeaders)
        //print("Canonical Headers:\n\(canonicalHeaders)\n***\n")

        // Task 1 is the Canonical Request
        let canonicalRequest = try getCanonicalRequest(
            payloadHash: payloadHash,
            method: method,
            path: path,
            query: query ?? "",
            canonicalHeaders: canonicalHeaders,
            signedHeaders: signedHeaders
        )
        //print("Canonical Request:\n\(canonicalRequest)\n***\n")

        let canonicalHash = try Hash.make(.sha256, canonicalRequest).hexString
        //print("Canonical hash: \(canonicalHash)")

        // Task 2 is the String to Sign
        let stringToSign = getStringToSign(
            algorithm: algorithm,
            date: amzDate,
            scope: credentialScope,
            canonicalHash: canonicalHash
        )
        //print("String to sign:\n\(stringToSign)\n***\n")

        // Task 3 calculates Signature
        let signature = try getSignature(stringToSign)
        //print("Signature:\n\(signature)\n***\n")


        //Task 4 Add signing information to the request
        let authorizationHeader = createAuthorizationHeader(
            algorithm: algorithm,
            credentialScope: credentialScope,
            signature: signature,
            signedHeaders: signedHeaders
        )
      
      
        var requestHeaders: [HeaderKey: String] = [
            "X-Amz-Date": amzDate,
            "Content-Type": contentType,
            "Authorization": authorizationHeader,
            "Host": self.host
        ]
      
        headers.forEach { key, value in
            let headerKey = HeaderKey(stringLiteral: key)
            requestHeaders[headerKey] = value
        }
      
        return requestHeaders
    }
}
