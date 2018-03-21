import XCTest

import Foundation
import Sockets
import TLS
import Vapor

@testable import AWSDriver

struct FakeClient: Responder {
    init(hostname: String, port: Sockets.Port, securityLayer: SecurityLayer, proxy: Proxy?) throws {
        return
    }

    init() throws {
        try self.init(hostname: "fakehostname", port: 1337, securityLayer: SecurityLayer.tls(Context(.client)), proxy: nil)
    }

    func respond(to request: Request) throws -> Response {
        return Response(status: .ok, body: "{}".makeBody())
    }
}

class AWSDriverTests: XCTestCase {
    static var allTests = [
        ("testSubmitRequest", testSubmitRequest)
    ]

    func testSubmitRequest() throws {
        let driver = try AWSDriver(service: "fakeservice", region: .usEast1, accessKey: "fake-access", secretKey: "fake-secret", token: "fake-token", client: FakeClient())
        let response = try driver.submitRequest(baseURL: "baseURL.com", query: "query:fake", method: .get)
        XCTAssertEqual(response, "{}")
    }
}
