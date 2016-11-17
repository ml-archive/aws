import Foundation

class EC2 {

    let accessKey: String
    let secretKey: String
    let region: String

    public init(accessKey: String, secretKey: String, region: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = region
    }

    public func describeInstances() throws -> String {
        do {
            return try CallAWS().call(method: "GET", service: "ec2", host: "ec2.amazonaws.com", region: self.region, baseURL: "https://ec2.amazonaws.com", key: self.accessKey, secret: self.secretKey, requestParam: "Action=DescribeInstances")
        } catch {

        }

        return ""
    }
}
