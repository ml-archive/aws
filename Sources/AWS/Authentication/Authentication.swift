import Foundation
import HMAC
import Hash
import Essentials

class Authentication {

    let method: String
    let service: String
    let host: String
    let region: String
    let baseURL: String
    var amzDate: String
    let key: String
    let secret: String
    let requestParam: String

    public init(method: String, service: String, host: String, region: String, baseURL: String, key: String, secret: String, requestParam: String) {
        self.method = method
        self.service = service
        self.host = host
        self.region = region
        self.baseURL = baseURL
        self.amzDate = ""
        self.key = key
        self.secret = secret
        self.requestParam = requestParam
    }

    public func sign(_ key: String, _ msg: String) -> String {

        var data: [UInt8]
        var hexString: String

        hexString = ""

        do {
            let bytes = try HMAC.make(.sha256, msg, key: key)

            hexString = Data(bytes: bytes).hexEncodedString()

        } catch {

        }
        return hexString
    }

    public func createSignature(_ key: String, _ msg: String) -> String {
        var hexString: String

        hexString = ""

        do {
            let bytes = try HMAC.make(.sha256, msg, key: key)

            hexString = Data(bytes: bytes).hexEncodedString()
        } catch {

        }
        return hexString
    }

    public func getSignatureKey() -> String {
        let key = self.secret
        let kDate = sign("AWS4\(key)", dateStamp())
        let kRegion = sign(kDate, self.region)
        let kService = sign(kRegion, self.service)
        let kSigning = sign(kService, "aws4_request")

        return kSigning
    }

    public func canonicalRequest() -> String {
        var request: String

        request = ""

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
        var stringToSign: String

        stringToSign = ""

        do {
            //print(canonicalRequest())
            canonical = try Hash.make(.sha256, canonicalRequest())
            canonicalHash = Data(bytes: canonical).hexEncodedString()
            stringToSign = "\(algorithm)\n\(amzDate)\n\(credentialScope)\n\(canonicalHash)"
        } catch {
        }

        let signature = createSignature(getSignatureKey(), stringToSign)

        return "\(algorithm) Credential=\(self.key)/\(credentialScope), SignedHeaders=host;x-amz-date, Signature=\(signature)"
    }

    public func getAWSHeaders() -> Array<String> {
        amzDateHeader()

        return ["-H \"Authorization: \(authorizationHeader())\"",
                "-H \"x-amz-date: \(amzDate)\""]
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