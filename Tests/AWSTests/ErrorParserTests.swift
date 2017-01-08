import XCTest

@testable import Driver

class ErrorParserTests: XCTestCase {
    static var allTest = [
        ("testExample", testExample)
    ]
    
    func testExample() {
        XCTAssertEqual(2+2, 4)
    }
}
