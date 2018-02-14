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
    case noRolesPresent // This host does not have an associated Instance profile
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
        let role = try queryLocalEndpoint(urlPath: "http://169.254.169.254/latest/meta-data/iam/security-credentials/")
        if role.count < 1 {
            throw Error.noRolesPresent
        }
        return role
    }

    func generateIAMCreds() throws -> (String, String, String?) {
        let role = try findInstanceRole()
        let credString = try queryLocalEndpoint(urlPath: "http://169.254.169.254/latest/meta-data/iam/security-credentials/\(role)")
        let decoder = JSONDecoder()
        let credentials = try! decoder.decode(CredentialResponse.self, from: credString.data(using: .utf8)!)
        return (credentials.AccessKeyId, credentials.SecretAccessKey, credentials.Token)
    }
}

public struct AWSDriver {
    public let accessKey: String
    public let secretKey: String
    public let token: String?

    public init(accessKey: String? = nil, secretKey: String? = nil, token: String? = nil) throws {
        if let access = accessKey, let secret = secretKey {
            self.accessKey = access
            self.secretKey = secret
            self.token = token
        } else {
            (self.accessKey, self.secretKey, self.token) = try InstanceProfile().generateIAMCreds()
        }
    }
}
