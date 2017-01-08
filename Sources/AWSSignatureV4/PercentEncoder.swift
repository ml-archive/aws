import Core

extension Byte {
    public static let awsQueryAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~=".bytes
    
    public static let awsPathAllowed  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/".bytes
}

extension String {
    public func percentEncode(allowing allowed: Bytes) throws -> String {
        let bytes = self.bytes
        let encodedBytes = try percentEncodedUppercase(bytes, shouldEncode: {
            return !allowed.contains($0)
        })
        return encodedBytes.string
    }
}

func percentEncodedUppercase(
    _ input: [Byte],
    shouldEncode: (Byte) throws -> Bool = { _ in true }
) throws -> [Byte] {
    var group: [Byte] = []
    try input.forEach { byte in
        if try shouldEncode(byte) {
            let hex = String(byte, radix: 16).uppercased().utf8
            group.append(.percent)
            if hex.count == 1 {
                group.append(.zero)
            }
            group.append(contentsOf: hex)
        } else {
            group.append(byte)
        }
    }
    return group
}
