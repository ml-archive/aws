import Core
import Hash

public enum Payload {
    case bytes(Bytes)
    case unsigned
    case none
}

extension Payload {
    func hashed() throws -> String {
        switch self {
        case .bytes(let bytes):
            return try Hash.make(.sha256, bytes).hexString
            
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
            
        case .none:
            return try Hash.make(.sha256, []).hexString
        }
    }
}

extension Payload {
    var bytes: Bytes {
        switch self {
        case .bytes(let bytes):
            return bytes
            
        default:
            return []
        }
    }
}

extension Payload: Equatable {
    public static func ==(lhs: Payload, rhs: Payload) -> Bool {
        switch (lhs, rhs) {
        case (.bytes, .bytes), (.unsigned, .unsigned), (.none, .none):
            return true
            
        default:
            return false
        }
    }
}
