import Debugging

public enum VaporS3Error: Debuggable {
    case s3NotFound
}

extension VaporS3Error {
    public var identifier: String {
        return "s3NotFound"
    }

    public var reason: String {
        return "s3 didn't exist in droplet"
    }

    public var possibleCauses: [String] {
        return [
            "you're accessing drop.s3() before the provider has been added and booted properly"
        ]
    }

    public var suggestedFixes: [String] {
        return [
            "make sure you're adding the s3 provider with `drop.addProvider`",
            "do not call `drop.s3()` until AFTER the provider has been added"
        ]
    }
}
