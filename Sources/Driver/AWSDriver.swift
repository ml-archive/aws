import HTTP
import Transport

public enum AccessControlList: String {
    case privateAccess = "private"
    case publicRead = "public-read"
    case publicReadWrite = "public-read-write"
    case awsExecRead = "aws-exec-read"
    case authenticatedRead = "authenticated-read"
    case bucketOwnerRead = "bucket-owner-read"
    case bucketOwnerFullControl = "bucket-owner-full-control"
}

class AWSDriver {
    enum Error: Swift.Error {
        case unsupported(String)
    }
    
    public func put() {
    }
    
    public func get() {
    }
    
    public func delete() {
        
    }
    
    public func call(authentication: Authentication) throws -> Response {
        let headers = authentication.getCanonicalHeaders()

        let response: Response
        switch authentication.method {
        case .get:
            response = try BasicClient.get(
                "\(authentication.baseURL)?\(authentication.requestParam)",
                headers: headers
            )
            
        default:
            throw Error.unsupported("method: \(authentication.method)")
        }
        
        return response
    }
}
