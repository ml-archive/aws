/**
    All tests are based off of Amazon's Signature Test Suite
    See: http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html
 */

import XCTest

import HTTP
import Foundation

@testable import Driver

class SignatureTestSuite: XCTestCase {
    static var allTests = [
        ("testPostVanilla", testPostVanilla),
        ("testPostVanillaEmptyQuery", testPostVanillaEmptyQuery)
    ]
    
    static let dateFormatter: DateFormatter  = {
        let _dateFormatter = DateFormatter()
        _dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        _dateFormatter.dateFormat = "YYYYMMdd'T'HHmmss'Z'"
        return _dateFormatter
    }()
    
    func testPostVanilla() {
        let expectedCanonicalRequest = "POST\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5da7c1a2acd57cee7505fc6676e4e544621c30862966e37dddb68e92efbe5d6b"
        ]
        
        let result = post(path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testPostVanillaEmptyQuery() {
        let expectedCanonicalRequest = "POST\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11"
        ]
        
        let result = post(path: "/", requestParam: "Param1=value1")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
}

extension SignatureTestSuite {
    var testDate: Date {
        return SignatureTestSuite.dateFormatter.date(from: "20150830T123600Z")!
    }
    
    func post(path: String, requestParam: String? = nil) -> SignerResult {
        var auth = Driver.Authentication(
            method: .post,
            service: "service",
            host: "example.amazonaws.com",
            region: "us-east-1",
            baseURL: path,
            key: "AKIDEXAMPLE",
            secret: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
            requestParam: requestParam
        )
        
        auth.unitTestDate = testDate
        
        let canonicalRequest = auth.getCanonicalRequest()
        let credentialScope = auth.getCredentialScope()
        let canonicalHeaders = auth.getCanonicalHeaders()
        
        return SignerResult(
            canonicalRequest: canonicalRequest,
            credentialScope: credentialScope,
            canonicalHeaders: canonicalHeaders
        )
    }
}
