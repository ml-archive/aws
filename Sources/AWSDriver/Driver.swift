public protocol Driver {
    var accessKey: String { get }
    var secretKey: String { get }
    var token: String? { get }

    func get(baseURL: String, query: String) throws -> String
    func post(baseURL: String, query: String, body: String) throws -> String
}
