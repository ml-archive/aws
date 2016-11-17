import Foundation

class EC2 {

    let accessKey: String
    let secretKey: String
    let region: String
    let service: String
    let host: String
    let baseURL: String

    public init(accessKey: String, secretKey: String, region: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = region
        self.service = "ec2"
        self.host = "\(self.service).amazonaws.com"
        self.baseURL = "https://\(self.host)"
    }

    public func describeInstances() throws -> String {
        do {
            return try CallAWS().call(
                    method: "GET",
                    service: self.service,
                    host: self.host,
                    region: self.region,
                    baseURL: self.baseURL,
                    key: self.accessKey,
                    secret: self.secretKey,
                    requestParam: "Action=DescribeRegions&Version=2015-10-01")
        } catch {

        }

        return ""
    }
}
