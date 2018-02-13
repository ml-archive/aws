import Foundation

import AWSSignatureV4
import Vapor
import HTTP

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

public enum Error: Swift.Error {
    case roleError // Problem getting IAM role credentials
}

struct InstanceProfile {
    func queryLocalEndpoint(urlPath: String) throws -> String {
        let client = try EngineClientFactory.init().makeClient(hostname:
            "169.254.169.254", port: 80, securityLayer: .none, proxy: nil)
        let version = HTTP.Version(major: 1, minor: 1)
        let request = HTTP.Request(method: Method.get, uri: urlPath, version: version, headers: [:], body: Body.data(Bytes([])))
        let response = try client.respond(to: request)
        guard let bytes = response.body.bytes else {
            throw Error.roleError
        }
        return bytes.makeString()

    }

    func findInstanceRole() throws -> String {
        return try queryLocalEndpoint(urlPath: "http://169.254.169.254/latest/meta-data/iam/security-credentials/")

    }

    func generateIAMCreds() throws -> (String, String) {
        let role = try findInstanceRole()
        let credString = try queryLocalEndpoint(urlPath: "http://169.254.169.254/latest/meta-data/iam/security-credentials/\(role)")
        let decoder = JSONDecoder()
        let credentials = try! decoder.decode(CredentialResponse.self, from: credString.data(using: .utf8)!)
        return (credentials.AccessKeyId, credentials.SecretAccessKey)
    }
}

public struct AWSDriver {
    public let accessKey: String
    public let secretKey: String

    public init(accessKey: String? = nil, secretKey: String? = nil) throws {
        if let access = accessKey, let secret = secretKey {
            self.accessKey = access
            self.secretKey = secret
        } else {
            (self.accessKey, self.secretKey) = try InstanceProfile().generateIAMCreds()
        }
    }
}
