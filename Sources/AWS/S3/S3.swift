import Foundation
import Console

class S3 {
    let console: ConsoleProtocol = Terminal(arguments: CommandLine.arguments)

    let accessKey: String
    let keySecret: String
    let region: String
    let bucket: String
    let service: String
    let host: String
    let baseURL: String

    public init(accessKey: String, keySecret: String, region: String, bucket: String) {
        self.accessKey = accessKey
        self.keySecret = keySecret
        self.region = region
        self.bucket = bucket
        self.service = "s3"
        self.host = "\(self.service).amazonaws.com"
        self.baseURL = "https://\(self.host)"
    }

    public func upload(file: String, folder: String) throws {
        /*let method = "PUT"

        do {

        }*/
    }

    public func exist(file: String) {

    }

    public func get(file: String) {

    }

    public func delete(file: String) {

    }
}
