import AWSSignatureV4
import HTTP
import TLS
import Vapor

struct CredentialResponse: Codable {
    enum Success: String, Codable {
        case Success
    }

    let Code: Success
    let LastUpdated: String
    let awsType: String
    let AccessKeyId: String
    let SecretAccessKey: String
    let Token: String
    let Expiration: String

    enum CodingKeys: String, CodingKey {
        case Code, LastUpdated, AccessKeyId, SecretAccessKey, Token, Expiration
        case awsType = "Type"
    }
}


public struct AWSDriver: Driver {
    public enum Error: Swift.Error {
        case invalidResponse(Status)
    }

    public let accessKey: String
    public let secretKey: String
    public let token: String?
    let service: String
    let host: String
    let signer: AWSSignatureV4
    var client: Responder

    public init(service: String, region: Region? = nil, accessKey: String? = nil, secretKey: String? = nil, token: String? = nil, client: Responder? = nil) throws {
        self.service = service
        var serviceRegion =  Region.usEast1
        if let awsRegion = region {
            self.host = "\(self.service).\(awsRegion.rawValue).amazonaws.com"
            serviceRegion = awsRegion
        } else {
            self.host = "\(self.service).amazonaws.com"
        }
        if let client = client {
            self.client = client
        } else {
            self.client = try EngineClientFactory().makeClient(hostname: host, port: 443, securityLayer: .tls(Context(.client)), proxy: nil)
        }
        if let access = accessKey, let secret = secretKey {
            self.accessKey = access
            self.secretKey = secret
            self.token = token
        } else {
            (self.accessKey, self.secretKey, self.token) = try InstanceProfile().generateIAMCreds()
        }

        self.signer = AWSSignatureV4(
            service: self.service,
            host: self.host,
            region: serviceRegion,
            accessKey: self.accessKey,
            secretKey: self.secretKey,
            token: self.token
        )
    }
}

extension AWSDriver {
    func submitRequest(baseURL: String, query: String, method: HTTP.Method, body: String? = nil) throws -> String {

        let signerMethod = method == .post ? AWSSignatureV4.Method.post : AWSSignatureV4.Method.get

        let payloadBytes: Bytes
        let payload: Payload
        if let messageBody = body {
            payloadBytes = messageBody.makeBytes()
            payload = Payload.bytes(payloadBytes)
        } else {
            payloadBytes = Bytes([])
            payload = .none
        }

        let uri = "\(baseURL)/?\(query)"
        let headers = try signer.sign(payload: payload, method: signerMethod, path: "/", query: query)

        let version = HTTP.Version(major: 1, minor: 1)
        let request = HTTP.Request(method: method, uri: uri, version: version, headers: headers, body: Body.data(payloadBytes))
        let response = try client.respond(to: request)

        guard response.status == .ok else {
            print("Response error: \(response)")
            guard let bytes = response.body.bytes else {
                throw Error.invalidResponse(response.status)
            }

            throw try ErrorParser.parse(bytes)
        }

        guard let bytes = response.body.bytes else {
            throw Error.invalidResponse(.internalServerError)
        }

        return bytes.makeString()
    }

    public func get(baseURL: String, query: String) throws -> String {
        return try submitRequest(baseURL: baseURL, query: query, method: .get)
    }

    public func post(baseURL: String, query: String, body: String) throws -> String {
        return try submitRequest(baseURL: baseURL, query: query, method: .post, body: body)
    }
}
