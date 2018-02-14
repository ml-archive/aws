import Foundation
import HTTP
import TLS
import SWXMLHash
import AWSSignatureV4
import AWSDriver
import Vapor

public struct ModifyInstanceAttributeResponse {
    public let requestId: String
    public let returnValue: Bool
}

public enum ModifiableAttributes {
    case instanceType
    case kernel
    case ramdisk
    case userData
    case disableApiTermination
    case instanceInitiatedShutdownBehavior
    case rootDeviceName
    case blockDeviceMapping
    case productCodes
    case sourceDestCheck
    case groupSet
    case ebsOptimized
    case sriovNetSupport
    case enaSupport
}

public class EC2 {
    public enum Error: Swift.Error {
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
        self.service = "ec2"
        self.host = "\(self.service).\(region.rawValue).amazonaws.com"
        self.baseURL = "https://\(self.host)"
        if driver == nil {
            self.driver = try AWSDriver(service: service, region: region)
        } else {
            self.driver = driver!
        }
        self.signer = AWSSignatureV4(
            service: self.service,
            host: self.host,
            region: self.region,
            accessKey: self.driver.accessKey,
            secretKey: self.driver.secretKey,
            token: self.driver.token
        )
    }

    func generateQuery(for action: String, instanceId: String, securityGroup: String? = nil) -> String {
        var query = "Action=\(action)&InstanceId=\(instanceId)"
        if let sg = securityGroup {
            query = "\(query)&GroupId.1=\(sg)"
        }
        query = "\(query)&Version=2016-11-15"
        return query
    }

    /**
     Change the configuration of a running instance. Many attributes require the instance to be stopped before being changed. Please [see the docs for details](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyInstanceAttribute.html).

     - returns:
        Success or failure of the operation

     - parameters:
        - instanceID: Unique identifier of the form `i-<value>`
        - securityGroup: Security group to attach to this instance
    */
    public func modifyInstanceAttribute(instanceId: String, securityGroup: String? = nil) throws -> ModifyInstanceAttributeResponse? {
        let query = generateQuery(for: "ModifyInstanceAttribute", instanceId: instanceId, securityGroup: securityGroup)
        let output = try driver.post(baseURL: baseURL, query: query)

        let xml = SWXMLHash.parse(output)
        let modifyResponse = xml["ModifyInstanceAttributeResponse"]

        if let requestId = modifyResponse["requestId"].element?.text, let returnStringValue = modifyResponse["return"].element?.text, let returnValue = Bool(returnStringValue) {
            return ModifyInstanceAttributeResponse(requestId: requestId, returnValue: returnValue)
        }
        return nil
    }
}
