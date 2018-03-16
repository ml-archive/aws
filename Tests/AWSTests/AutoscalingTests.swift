import XCTest

import HTTP
import Foundation

@testable import AutoScaling

class AutoscalingTests: XCTestCase {
    static var allTests = [
        ("testGenerateQuery", testGenerateQuery)
    ]

    func testGenerateQuery() {
        let autoscaling = AutoScaling(accessKey: "fake", secretKey: "secret", region: "us-east-1")
        let query = autoscaling.generateQuery(for: "Action", name: "autoscaling-name")
        XCTAssertEqual(query, "Action=Action&AutoScalingGroupNames.member.1=autoscaling-name&Version=2011-01-01")
    }
}
