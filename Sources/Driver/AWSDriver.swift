import HTTP
import Transport

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
    
    public func call(authentication: AWSSignatureV4) throws -> Response {
        /*let headers = authentication.getCanonicalHeaders()

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
        
        return response*/
        
        throw Error.unsupported("call(authentiction:)")
    }
}
