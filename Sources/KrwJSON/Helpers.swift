struct DummyCodable: Decodable {}

extension UnkeyedDecodingContainer {

    func skipped(_ count: Int) throws -> Self {
        var result = self
        while result.currentIndex <= count {
            try result.skip(1)
        }
        return result
    }

    mutating func skip(_ count: Int) throws {
        _ = try decode(DummyCodable.self)
    }
}
