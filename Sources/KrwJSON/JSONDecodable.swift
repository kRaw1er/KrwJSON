public protocol JSONDecodable: Decodable {
    init(json: JSON) throws
}

public extension JSONDecodable {
    init(from decoder: Decoder) throws {
        try self.init(json: JSON(from: decoder))
    }
}
