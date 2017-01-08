import XCTest

import HTTP

struct SignerResult {
    let canonicalRequest: String
    let credentialScope: String
    let canonicalHeaders: [HeaderKey: String]
}

extension SignerResult {
    func expect(
        canonicalRequest: String,
        credentialScope: String,
        canonicalHeaders: [HeaderKey: String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        //XCTAssertEqual(self.canonicalRequest, canonicalRequest, file: file, line: line)
        XCTAssertEqual(self.credentialScope, credentialScope, file: file, line: line)

        canonicalHeaders.forEach {
            XCTAssertEqual(self.canonicalHeaders[$0.key], $0.value, file: file, line: line)
        }
    }
}
