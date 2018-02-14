import HTTP
import Vapor
import Core
import Transport
import AWSSignatureV4
import AWSDriver
import TLS
import Node
import SWXMLHash

@_exported import enum AWSSignatureV4.AWSError
@_exported import enum AWSSignatureV4.AccessControlList

public enum LifeCycleState {
    case InService
}

public enum HealthStatus {
    case Healthy
}

public struct Instance {
    public let state: LifeCycleState
    public let instanceID: String
    public let status: HealthStatus
    public let protectedFromScaleIn: Bool
    public let availabilityZone: String
}

public struct AutoScaling {
    public enum Error: Swift.Error {
        case InvalidNextToken // The NextToken value is not valid.
        case ResourceContention // You already have a pending update to an Auto Scaling resource (for example, a group, instance, or load balancer).
        case invalidResponse(Status)
    }

    let region: Region
    let service: String
    let host: String
    let baseURL: String
    let signer: AWSSignatureV4
    let driver: AWSDriver

    public init(region: Region, driver: AWSDriver? = nil) throws {
        self.region = region
        if driver == nil {
            self.driver = try AWSDriver()
        } else {
            self.driver = driver!
        }
        self.service = "autoscaling"
        self.host = "\(self.service).amazonaws.com"
        self.baseURL = "https://\(self.host)"
        self.signer = AWSSignatureV4(
            service: self.service,
            host: self.host,
            region: self.region,
            accessKey: self.driver.accessKey,
            secretKey: self.driver.secretKey,
            token: self.driver.token
        )
    }

    func generateQuery(for action: String, name: String) -> String {
        return "Action=\(action)&AutoScalingGroupNames.member.1=\(name)&Version=2011-01-01"
    }

    /*
     * http://docs.aws.amazon.com/AutoScaling/latest/APIReference/API_DescribeAutoScalingGroups.html
     */
    public func describeAutoScalingGroups(name: String) throws -> [Instance] {
        let query = generateQuery(for: "DescribeAutoScalingGroups", name: name)
        let headers = try signer.sign(path: "/", query: query)
        let client = try EngineClientFactory().makeClient(hostname: host, port: 443, securityLayer: .tls(Context.init(.client)), proxy: nil)

        print("\(baseURL)/?\(query)")
        print(headers)
        let version = HTTP.Version(major: 1, minor: 1)
        let request = HTTP.Request(method: Method.get, uri: "\(baseURL)/?\(query)", version: version, headers: headers, body: Body.data(Bytes([])))
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

        let output = bytes.makeString()
        let xml = SWXMLHash.parse(output)
        let autoscalingGroupXML = xml["DescribeAutoScalingGroupsResponse"]["DescribeAutoScalingGroupsResult"]["AutoScalingGroups"]["member"]

        var autoscalingGroup = [Instance]()
        for member in autoscalingGroupXML["Instances"].children {
            if let instanceId = member["InstanceId"].element?.text, let availabilityZone = member["AvailabilityZone"].element?.text {
                autoscalingGroup.append(Instance(state: .InService, instanceID: instanceId, status: .Healthy, protectedFromScaleIn: false, availabilityZone: availabilityZone))
            }
        }
        return autoscalingGroup
    }
}
