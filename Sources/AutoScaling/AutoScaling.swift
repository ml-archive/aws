import HTTP
import Core
import Transport
import AWSSignatureV4

@_exported import enum AWSSignatureV4.AWSError
@_exported import enum AWSSignatureV4.AccessControlList

public struct AutoScaling {
    public enum Error: Swift.Error {
        case InvalidNextToken // The NextToken value is not valid.
        case ResourceContention // You already have a pending update to an Auto Scaling resource (for example, a group, instance, or load balancer).
        case invalidResponse(Status)
    }

    let accessKey: String
    let secretKey: String
    let region: Region
    let service: String
    let host: String
    let baseURL: String
    let signer: AWSSignatureV4

    public init(accessKey: String, secretKey: String, region: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = Region(rawValue: region)!
        self.service = "autoscaling"
        self.host = "\(self.service).amazonaws.com"
        self.baseURL = "https://\(self.host)"
        self.signer = AWSSignatureV4(
            service: self.service,
            host: self.host,
            region: self.region,
            accessKey: accessKey,
            secretKey: secretKey
        )
    }

    func generateURL(for action: String, name: String) -> String {
        return "\(baseURL)/?Action=\(action)&AutoScalingGroupNames.member.1=\(name)&Version=2011-01-01"
    }

    /*
     * http://docs.aws.amazon.com/AutoScaling/latest/APIReference/API_DescribeAutoScalingGroups.html
     */
    public func describeAutoScalingGroups(name: String) throws -> String {
        let url = generateURL(for: "DescribeAutoScalingGroups", name: name)
        let query = "Action=DescribeAutoScalingGroups&AutoScalingGroupNames.member.1=\(name)&Version=2011-01-01"

        let headers = try signer.sign(path: "/", query: query)

        let response = try BasicClient.get(url, headers: headers)
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

        return bytes.string
    }
}
