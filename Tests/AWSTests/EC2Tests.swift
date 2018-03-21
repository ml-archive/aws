import XCTest

import AWSDriver

@testable import EC2

struct FakeDriver: Driver {
    var accessKey: String
    var secretKey: String
    var token: String?

    func get(baseURL: String, query: String) throws -> String {
        return "get"
    }

    func post(baseURL: String, query: String, body: String) throws -> String {
        return "<ModifyInstanceAttributeResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\"><requestId>9001</requestId><return>true</return></ModifyInstanceAttributeResponse>"
    }
}

class EC2Tests: XCTestCase {
    static var allTests = [
        ("testModifyInstanceAttribute", testModifyInstanceAttribute)
    ]

    func testModifyInstanceAttribute() throws {
        let driver = FakeDriver(accessKey: "fake-access", secretKey: "fake-secret", token: "fake-token")
        let fakeResponse = ModifyInstanceAttributeResponse(requestId: "9001", returnValue: true)

        let client = try EC2(region: .usEast1, driver: driver)
        let response = try client.modifyInstanceAttribute(instanceId: "i-9001", securityGroup: "very-secure")
        XCTAssertEqual(response, fakeResponse)
    }
}
