import Core

public struct ErrorParser {
    static let codeBytes: Bytes = [.C, .o, .d, .e, .greaterThan]
    enum Error: Swift.Error {
        case unknownError(String)
        case couldNotFindErrorTag
    }
    
    var scanner: Scanner<Byte>
    
    init(scanner: Scanner<Byte>) {
        self.scanner = scanner
    }
}

extension ErrorParser {
    public static func parse(_ bytes: Bytes) throws -> AWSError {
        var parser = ErrorParser(scanner: Scanner(bytes))
        return try parser.extractError()
    }
}

extension ErrorParser {
    mutating func extractError() throws -> AWSError {
        while scanner.peek() != nil {
            skip(until: .lessThan)
            
            // check for `<Code>`
            guard checkForCodeTag() else {
                continue
            }
            
            let errorBytes = consume(until: .lessThan)
            
            guard let error = ErrorParser.awsGrammar.contains(errorBytes) else {
                throw Error.unknownError(errorBytes.string)
            }
            
            return error
        }
        
        throw Error.couldNotFindErrorTag
    }
    
    mutating func checkForCodeTag() -> Bool {
        scanner.pop()
        
        for (index, byte) in ErrorParser.codeBytes.enumerated() {
            guard
                let preview = scanner.peek(aheadBy: index),
                preview == byte
            else {
                return false
            }
        }
        
        scanner.pop(ErrorParser.codeBytes.count)
        
        return true
    }
}

extension ErrorParser {
    mutating func skip(until terminator: Byte) {
        var count = 0
        
        while let byte = scanner.peek(aheadBy: count), byte != terminator {
            count += 1
        }
        
        scanner.pop(count)
    }
    
    mutating func consume(until terminator: Byte) -> Bytes {
        var bytes: [Byte] = []
        
        while let byte = scanner.peek(), byte != terminator {
            scanner.pop()
            bytes.append(byte)
        }
        
        return bytes
    }
}

extension Byte {
    /// <
    static let lessThan: Byte = 0x3C
    
    /// >
    static let greaterThan: Byte = 0x3E
    
    /// lowercase `d`
    static let d: Byte = 0x64
    
    /// lowercase `e`
    static let e: Byte = 0x65
    
    /// lowercase `o`
    static let o: Byte = 0x6F
}
