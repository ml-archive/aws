import Foundation

import HTTP
import Vapor

struct InstanceProfile {
    public enum Error: Swift.Error {
        case roleError // Problem getting IAM role credentials
        case noRolesPresent // This host does not have an associated Instance profile
    }

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
