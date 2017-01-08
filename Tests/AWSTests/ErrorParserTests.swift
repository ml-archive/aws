import XCTest

@testable import AWSSignatureV4

class ErrorParserTests: XCTestCase {
    static var allTest = [
        ("testExample", testExample)
    ]
    
    func testExample() {
        XCTAssertEqual(2+2, 4)
    }
}
