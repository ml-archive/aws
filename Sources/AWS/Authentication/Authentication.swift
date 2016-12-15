import Core
import Hash
import HMAC
import HTTP
import Essentials
import Foundation

class Authentication {
    enum Method {
        case get
        case post
    }
    
    let method: Method
    let service: String
    let host: String
    let region: String
    let baseURL: String
    var amzDate: String
    let key: String
    let secret: String
    let requestParam: String!

    public init(method: Method, service: String, host: String, region: String, baseURL: String, key: String, secret: String, requestParam: String!) {
        self.method = method
        self.service = service
        self.host = host
        self.region = region
        self.baseURL = baseURL
        self.amzDate = ""
        self.key = key
        self.secret = secret
        self.requestParam = requestParam.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    public func getSignature(stringToSign: String) throws -> String {
        let dateHMAC = try HMAC.make(.sha256, dateStamp().bytes, key: "AWS4\(self.secret)".bytes)
        let regionHMAC = try HMAC.make(.sha256, self.region.bytes, key: dateHMAC)
        let serviceHMAC = try HMAC.make(.sha256, self.service.bytes, key: regionHMAC)
        let signingHMAC = try HMAC.make(.sha256, "aws4_request".bytes, key: serviceHMAC)

        let signature = try HMAC.make(.sha256, stringToSign.bytes, key: signingHMAC)

        return Data(bytes: signature).hexEncodedString()
    }

    public func canonicalRequest() -> String {
        var request: String = ""

        let uri = "/"
        let queryString = self.requestParam
        let headers = "host:\(host)\nx-amz-date:\(amzDate)\n"
        let signedHeaders = "host;x-amz-date"
        var payload: [UInt8]
        var payloadHash: String

        do {
            payload = try Hash.make(.sha256, "")
            payloadHash = Data(bytes: payload).hexEncodedString()
            request = "\(method)\n\(uri)\n\(queryString)\n\(headers)\n\(signedHeaders)\n\(payloadHash)"
        } catch {

        }

        return request
    }

    public func authorizationHeader() -> String {
        let algorithm = "AWS4-HMAC-SHA256"
        let credentialScope = "\(dateStamp())/\(self.region)/\(self.service)/aws4_request"
        let canonicalHash: String
        let canonical: [UInt8]
        var stringToSign: String = ""

        do {
            canonical = try Hash.make(.sha256, canonicalRequest())
            canonicalHash = Data(bytes: canonical).hexEncodedString()
            stringToSign = "\(algorithm)\n\(amzDate)\n\(credentialScope)\n\(canonicalHash)"
        } catch {
        }

        var signature: String = ""
        do {
            signature = try getSignature(stringToSign: stringToSign)
        } catch {

        }

        return "\(algorithm) Credential=\(self.key)/\(credentialScope), SignedHeaders=host;x-amz-date, Signature=\(signature)"
    }

    public func getAWSHeaders() -> [HeaderKey : String] {
        amzDateHeader()
        return [
            "Authorization": authorizationHeader(),
            "x-amz-date": amzDate
        ]
    }

    public func amzDateHeader() {
        let date = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YYYYMMdd'T'HHmmss'Z'"

        self.amzDate = dateFormatter.string(from: date)
    }

    public func dateStamp() -> String {
        let date = Date()

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "YYYYMMdd"

        return dateFormatter.string(from: date)
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
