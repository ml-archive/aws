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
        self.host = "\(self.service).amazonaws.com"
        self.baseURL = "https://\(self.host)"
        if driver == nil {
            self.driver = try AWSDriver()
        } else {
            self.driver = driver!
        }
        self.signer = AWSSignatureV4(
            service: self.service,
            host: self.host,
            region: self.region,
            accessKey: self.driver.accessKey,
            secretKey: self.driver.secretKey
        )
    }

    func generateQuery(for action: String, instanceId: String) -> String {
        return "Action=\(action)&InstanceID=\(instanceId)&Version=2016-11-15"
    }

    /**
     Change the configuration of a running instance. Many attributes require the instance to be stopped before being changed. Please [see the docs for details](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyInstanceAttribute.html).

     - returns:
        Success or failure of the operation

     - parameters:
        - instanceID: Unique identifier of the form `i-<value>`
    */
    public func modifyInstanceAttribute(instanceId: String, securityGroup: String? = nil) throws -> ModifyInstanceAttributeResponse? {
        var query = generateQuery(for: "ModifyInstanceAttribute", instanceId: instanceId)
        if let sg = securityGroup {
            query = "\(query)&GroupId.N=\(sg)"
        }
        print("\(baseURL)/?\(query)")
        let headers = try signer.sign(path: "/", query: query)
        let client = try EngineClientFactory.init().makeClient(hostname: host, port: 443, securityLayer: .tls(Context.init(.client)), proxy: nil)

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
        let modifyResponse = xml["ModifyInstanceAttributeResponse"]

        if let requestId = modifyResponse["requestId"].element?.text, let returnStringValue = modifyResponse["return"].element?.text, let returnValue = Bool(returnStringValue) {
            return ModifyInstanceAttributeResponse(requestId: requestId, returnValue: returnValue)
        }
        return nil
    }

    func describeInstances() throws -> String {
        //TODO(Brett): wrap this result in a model instead of a string type
        /*let response =  try AWSDriver().call(
            method: .get,
            service: service,
            host: host,
            region: region,
            baseURL: baseURL,
            key: accessKey,
            secret: secretKey,
            requestParam: "Action=DescribeRegions&Version=2015-10-01"
        )
        
        return response.description*/
        return ""
    }
}
