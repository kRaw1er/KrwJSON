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
