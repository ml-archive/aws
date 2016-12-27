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
        ("testGetUnreserved", testGetUnreserved),
        ("testGetUTF8", testGetUTF8),
        ("testGetVanilla", testGetVanilla),
        ("testGetVanillaQuery", testGetVanillaQuery),
        ("testGetVanillaEmptyQueryKey", testGetVanillaEmptyQueryKey),
        ("testPostVanilla", testPostVanilla),
        ("testPostVanillaQuery", testPostVanillaQuery),
        ("testPostVanillaQueryNonunreserved", testPostVanillaQueryNonunreserved)
    ]
    
    static let dateFormatter: DateFormatter  = {
        let _dateFormatter = DateFormatter()
        _dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        _dateFormatter.dateFormat = "YYYYMMdd'T'HHmmss'Z'"
        return _dateFormatter
    }()
    
    func testGetUnreserved() {
        let expectedCanonicalRequest = "GET\n/-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=07ef7494c76fa4850883e2b006601f940f8a34d404d0cfa977f52a65bbf5f24f"
        ]
        
        let result = sign(
            method: .get,
            path: "/-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        )
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testGetUTF8() {
        let expectedCanonicalRequest = "GET\n/%E1%88%B4\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=8318018e0b0f223aa2bbf98705b62bb787dc9c0e678f255a891fd03141be5d85"
        ]
        
        let result = sign(method: .get, path: "/ሴ")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testGetVanilla() {
        let expectedCanonicalRequest = "GET\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31"
        ]
        
        let result = sign(method: .get, path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    //duplicate as `testGetVanilla`, but is in Amazon Test Suite
    //will keep until I figure out why there's a duplicate test
    func testGetVanillaQuery() {
        let expectedCanonicalRequest = "GET\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31"
        ]
        
        let result = sign(method: .get, path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testGetVanillaEmptyQueryKey() {
        let expectedCanonicalRequest = "GET\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=a67d582fa61cc504c4bae71f336f98b97f1ea3c7a6bfe1b6e45aec72011b9aeb"
        ]
        
        let result = sign(method: .get, path: "/", requestParam: "Param1=value1")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testPostVanilla() {
        let expectedCanonicalRequest = "POST\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5da7c1a2acd57cee7505fc6676e4e544621c30862966e37dddb68e92efbe5d6b"
        ]
        
        let result = sign(method: .post, path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testPostVanillaQuery() {
        let expectedCanonicalRequest = "POST\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11"
        ]
        
        let result = sign(method: .post, path: "/", requestParam: "Param1=value1")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }
    
    func testPostVanillaQueryNonunreserved() {
        let expectedCanonicalRequest = "POST\n/\n%40%23%24%25%5E%26%2B=%2F%2C%3F%3E%3C%60%22%3B%3A%5C%7C%5D%5B%7B%7D\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"
        
        let expectedCanonicalHeaders: [HeaderKey : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=88d3e39e4fa54b971f51c0a09140368e1a51aafb76c4652d9998f93cf3038074"
        ]
        
        let result = sign(method: .post, path: "/", requestParam: "@#$%^&+=/,?><`\";:\\|][{}")
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
    
    func sign(
        method: Driver.Authentication.Method,
        path: String,
        requestParam: String? = nil
    ) -> SignerResult {
        var auth = Driver.Authentication(
            method: method,
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
