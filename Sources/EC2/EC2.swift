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
