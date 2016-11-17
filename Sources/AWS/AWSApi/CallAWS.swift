import Foundation
import Console

class CallAWS {
    let console: ConsoleProtocol = Terminal(arguments: CommandLine.arguments)

    public func call(method: String, service: String, host: String, region: String, baseURL: String, key: String, secret: String, requestParam: String) throws -> String {
        let headers = Authentication(
                method: method,
                service: service,
                host: host,
                region: region,
                baseURL: baseURL,
                key: key,
                secret: secret,
                requestParam: requestParam).getAWSHeaders()

        let header = headers.joined(separator: " ")

        do {
            let output = try console.backgroundExecute(program: "/bin/sh", arguments: [
                    "-c",
                    "curl -X \(method) \(header) \(host)?\(requestParam)"

            ])

            return output
        } catch ConsoleError.backgroundExecute(_, let message, _) {
            console.error(message.string)
        }

        return ""
    }
}