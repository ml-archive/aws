import HTTP
import Transport

class CallAWS {
    enum Error: Swift.Error {
        case unsupported(String)
    }
    
    public func call(
        method: Authentication.Method,
        service: String,
        host: String,
        region: String,
        baseURL: String,
        key: String,
        secret: String,
        requestParam: String
    ) throws -> Response {
        let headers = Authentication(
                method: method,
                service: service,
                host: host,
                region: region,
                baseURL: baseURL,
                key: key,
                secret: secret,
                requestParam: requestParam
            ).getAWSHeaders()

        let response: Response
        switch method {
        case .get:
            response = try BasicClient.get(
                "\(baseURL)?\(requestParam)",
                headers: headers
            )
            
        case .post:
            throw Error.unsupported("POST")
        }
        
        return response
    }
}
