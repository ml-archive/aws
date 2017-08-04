import XCTest
@testable import AWSTests

XCTMain([
    testCase(AWSTests.allTests),
    testCase(SignatureTestSuite.allTests),
    testCase(ErrorParserTests.allTests),
    testCase(AutoscalingTests.allTests),
])
