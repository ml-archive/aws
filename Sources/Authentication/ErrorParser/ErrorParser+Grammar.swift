import Core

extension ErrorParser {
    static let awsGrammar: Trie<AWSError> = {
        let trie = Trie<AWSError>()
        
        insert(into: trie, .accessDenied)
        insert(into: trie, .accountProblem)
        insert(into: trie, .ambiguousGrantByEmailAddress)
        insert(into: trie, .authorizationHeaderMalformed)
        insert(into: trie, .badDigest)
        insert(into: trie, .bucketAlreadyExists)
        insert(into: trie, .bucketAlreadyOwnedByYou)
        insert(into: trie, .bucketNotEmpty)
        insert(into: trie, .credentialsNotSupported)
        insert(into: trie, .crossLocationLoggingProhibited)
        insert(into: trie, .entityTooSmall)
        insert(into: trie, .entityTooLarge)
        insert(into: trie, .expiredToken)
        insert(into: trie, .illegalVersioningConfigurationException)
        insert(into: trie, .incompleteBody)
        insert(into: trie, .incorrectNumberOfFilesInPostRequest)
        insert(into: trie, .inlineDataTooLarge)
        insert(into: trie, .internalError)
        insert(into: trie, .invalidAccessKeyId)
        insert(into: trie, .invalidAddressingHeader)
        insert(into: trie, .invalidArgument)
        insert(into: trie, .invalidBucketName)
        insert(into: trie, .invalidDigest)
        insert(into: trie, .invalidEncryptionAlgorithmError)
        insert(into: trie, .invalidLocationConstraint)
        insert(into: trie, .invalidObjectState)
        insert(into: trie, .invalidPart)
        insert(into: trie, .invalidPartOrder)
        insert(into: trie, .invalidPayer)
        insert(into: trie, .invalidPolicyDocument)
        insert(into: trie, .invalidRange)
        insert(into: trie, .invalidRequest)
        insert(into: trie, .invalidSecurity)
        insert(into: trie, .invalidSOAPRequest)
        insert(into: trie, .invalidStorageClass)
        insert(into: trie, .invalidTargetBucketForLogging)
        insert(into: trie, .invalidToken)
        insert(into: trie, .invalidURI)
        insert(into: trie, .keyTooLong)
        insert(into: trie, .malformedACLError)
        insert(into: trie, .malformedPOSTRequest)
        insert(into: trie, .malformedXML)
        insert(into: trie, .maxMessageLengthExceeded)
        insert(into: trie, .maxPostPreDataLengthExceededError)
        insert(into: trie, .metadataTooLarge)
        insert(into: trie, .methodNotAllowed)
        insert(into: trie, .missingAttachment)
        insert(into: trie, .missingContentLength)
        insert(into: trie, .missingRequestBodyError)
        insert(into: trie, .missingSecurityElement)
        insert(into: trie, .missingSecurityHeader)
        insert(into: trie, .noLoggingStatusForKey)
        insert(into: trie, .noSuchBucket)
        insert(into: trie, .noSuchKey)
        insert(into: trie, .noSuchLifecycleConfiguration)
        insert(into: trie, .noSuchUpload)
        insert(into: trie, .noSuchVersion)
        insert(into: trie, .notImplemented)
        insert(into: trie, .notSignedUp)
        insert(into: trie, .noSuchBucketPolicy)
        insert(into: trie, .operationAborted)
        insert(into: trie, .peramentRedirect)
        insert(into: trie, .preconditionFailed)
        insert(into: trie, .redirect)
        insert(into: trie, .restoreAlreadyInProgress)
        insert(into: trie, .requestIsNotMultiPartContent)
        insert(into: trie, .requestTimeout)
        insert(into: trie, .requestTimeTooSkewed)
        insert(into: trie, .requestTorrentOfBucketError)
        insert(into: trie, .signatureDoesNotMatch)
        insert(into: trie, .serviceUnavailable)
        insert(into: trie, .slowDown)
        insert(into: trie, .temporaryRedirect)
        insert(into: trie, .tokenRefreshRequired)
        insert(into: trie, .tooManyBuckets)
        insert(into: trie, .unexpectedContent)
        insert(into: trie, .unresolvableGrantByEmailAddress)
        insert(into: trie, .userKeyMustBeSpecified)
        
        return trie
    }()
    
    static func insert(into trie: Trie<AWSError>, _ error: AWSError) {
        trie.insert(error, for: error.rawValue.bytes)
    }
}

/*
 case accessDenied
 case accountProblem
 case ambiguousGrantByEmailAddress
 case badDigest
 case bucketAlreadyExists
 case bucketAlreadyOwnedByYou
 case bucketNotEmpty
 case credentialsNotSupported
 case crossLocationLoggingProhibited
 case entityTooSmall
 case entityTooLarge
 case expiredToken
 case illegalVersioningConfigurationException
 case incompleteBody
 case incorrectNumberOfFilesInPostRequest
 case inlineDataTooLarge
 case internalError
 case invalidAccessKeyId
 case invalidAddressingHeader
 case invalidArgument
 case invalidBucketName
 case invalidDigest
 case invalidEncryptionAlgorithmError
 case invalidLocationConstraint
 case invalidObjectState
 case invalidPart
 case invalidPartOrder
 case invalidPayer
 case invalidPolicyDocument
 case invalidRange
 case invalidRequest
 case invalidSecurity
 case invalidSOAPRequest
 case invalidStorageClass
 case invalidTargetBucketForLogging
 case invalidToken
 case invalidURI
 case keyTooLong
 case malformedACLError
 case malformedPOSTRequest
 case malformedXML
 case maxMessageLengthExceeded
 case maxPostPreDataLengthExceededError
 case metadataTooLarge
 case methodNotAllowed
 case missingAttachment
 case missingContentLength
 case missingRequestBodyError
 case missingSecurityElement
 case missingSecurityHeader
 case noLoggingStatusForKey
 case noSuchBucket
 case noSuchKey
 case noSuchLifecycleConfiguration
 case noSuchUpload
 case noSuchVersion
 case notImplemented
 case notSignedUp
 case noSuchBucketPolicy
 case operationAborted
 case peramentRedirect
 case preconditionFailed
 case redirect
 case restoreAlreadyInProgress
 case requestIsNotMultiPartContent
 case requestTimeout
 case requestTimeTooSkewed
 case requestTorrentOfBucketError
 case signatureDoesNotMatch
 case serviceUnavailable
 case slowDown
 case temporaryRedirect
 case tokenRefreshRequired
 case tooManyBuckets
 case unexpectedContent
 case unresolvableGrantByEmailAddress
 case userKeyMustBeSpecified
 */
