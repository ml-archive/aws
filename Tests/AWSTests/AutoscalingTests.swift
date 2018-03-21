import XCTest

import HTTP
import Foundation

@testable import AutoScaling
import AWSDriver

class AutoscalingTests: XCTestCase {
    static var allTests = [
        ("testGenerateQuery", testGenerateQuery)
    ]

    func testGenerateQuery() throws {
        let driver = try AWSDriver(service: AutoScaling.service, region: .usEast1, accessKey: "fake-access", secretKey: "fake-secret", token: "fake-token")
        let autoscaling = try AutoScaling(driver: driver)
        let query = autoscaling.generateQuery(for: "Action", name: "autoscaling-name")
        XCTAssertEqual(query, "Action=Action&AutoScalingGroupNames.member.1=autoscaling-name&Version=2011-01-01")
    }
}
