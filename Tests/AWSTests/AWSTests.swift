import XCTest
import HTTP
import Transport
@testable import S3
@testable import Driver

class AWSTests: XCTestCase {
    static var allTests = [
        ("testExample", testExample)
    ]
    
    func testExample() {
        XCTAssertEqual(2+2, 4)
    }
}
