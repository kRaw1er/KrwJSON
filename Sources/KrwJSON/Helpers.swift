struct DummyCodable: Decodable {}

extension UnkeyedDecodingContainer {

    func skipped(_ count: Int) throws -> Self {
        var result = self
        while result.currentIndex <= count {
            _ = try result.decode(DummyCodable.self)
        }
        return result
    }
}
