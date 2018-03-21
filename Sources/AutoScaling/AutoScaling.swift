import Vapor
import Core
import Transport
import AWSDriver
import AWSSignatureV4
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
    }

    public static let service = "autoscaling"
    static let host = "\(AutoScaling.service).amazonaws.com"
    static let baseURL = "https://\(AutoScaling.host)"
    let driver: Driver

    public init(driver: Driver? = nil) throws {
        if driver == nil {
            self.driver = try AWSDriver(service: AutoScaling.service)
        } else {
            self.driver = driver!
        }
    }

    func generateQuery(for action: String, name: String) -> String {
        return "Action=\(action)&AutoScalingGroupNames.member.1=\(name)&Version=2011-01-01"
    }

    /*
     * http://docs.aws.amazon.com/AutoScaling/latest/APIReference/API_DescribeAutoScalingGroups.html
     */
    public func describeAutoScalingGroups(name: String) throws -> [Instance] {
        let query = generateQuery(for: "DescribeAutoScalingGroups", name: name)
        let output = try driver.get(baseURL: AutoScaling.baseURL, query: query)
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
