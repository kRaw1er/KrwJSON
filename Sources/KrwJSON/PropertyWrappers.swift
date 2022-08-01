import Foundation

@propertyWrapper
public struct JSONSafe<T: Decodable>: JSONDecodable {
    public var wrappedValue: T?

    public init(json: JSON) throws {
        wrappedValue = try? json.as(T.self)
    }
}

@propertyWrapper
public struct JSONCompactMap<T: Decodable>: JSONDecodable {
    public var wrappedValue: [T]

    public init(json: JSON) throws {
        wrappedValue = try json.compactMap()
    }
}

@propertyWrapper
public struct JSONSafeCompactMap<T: Decodable>: JSONDecodable {
    public var wrappedValue: [T]?

    public init(json: JSON) throws {
        wrappedValue = try? json.compactMap()
    }
}

extension JSONSafe: Hashable where T: Hashable {}
extension JSONSafe: Equatable where T: Equatable {}

extension JSONCompactMap: Hashable where T: Hashable {}
extension JSONCompactMap: Equatable where T: Equatable {}

extension JSONSafeCompactMap: Hashable where T: Hashable {}
extension JSONSafeCompactMap: Equatable where T: Equatable {}

