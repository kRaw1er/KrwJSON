@dynamicMemberLookup
public struct JSON: Decodable {
    typealias KeyedContainer = KeyedDecodingContainer<Key>
    typealias UnkeyedContainer = UnkeyedDecodingContainer

    enum ContainerWrapper {
        case decoder(Decoder)
        case keyedContainer(KeyedContainer, Key)
        case unkeyedContainer(UnkeyedContainer)

        var keyedContainer: KeyedContainer {
            get throws {
                switch self {
                case let .decoder(decoder):
                    return try decoder.container(keyedBy: Key.self)
                case let .keyedContainer(container, key):
                    return try container.nestedContainer(keyedBy: Key.self, forKey: key)
                case var .unkeyedContainer(container):
                    return try container.nestedContainer(keyedBy: Key.self)
                }
            }
        }

        var unkeyedContainer: UnkeyedContainer {
            get throws {
                switch self {
                case let .decoder(decoder):
                    return try decoder.unkeyedContainer()
                case let .keyedContainer(container, key):
                    return try container.nestedUnkeyedContainer(forKey: key)
                case var .unkeyedContainer(container):
                    return try container.nestedUnkeyedContainer()
                }
            }
        }
    }

    private let containerWrapper: ContainerWrapper

    public init(from decoder: Decoder) throws {
        self.init(containerWrapper: .decoder(decoder))
    }

    private init(containerWrapper: ContainerWrapper) {
        self.containerWrapper = containerWrapper
    }

    public subscript(_ key: String) -> JSON {
        get throws {
            try self[dynamicMember: key]
        }
    }

    public subscript(dynamicMember name: String) -> JSON {
        get throws {
            try JSON(containerWrapper: .keyedContainer(containerWrapper.keyedContainer, .key(name)))
        }
    }

    public subscript(_ index: Int) -> JSON {
        get throws {
            try JSON(containerWrapper: .unkeyedContainer(
                containerWrapper
                    .unkeyedContainer
                    .skipped(index - 1)
            ))
        }
    }

    public subscript<T: Decodable>(_ index: Int) -> T {
        get throws {
            var container = try containerWrapper
                .unkeyedContainer
                .skipped(index - 1)
            return try container.decode(T.self)
        }
    }

    public subscript<T: Decodable>(_ name: String) -> T {
        get throws {
            try self[dynamicMember: name]
        }
    }

    public subscript<T: Decodable>(dynamicMember name: String) -> T {
        get throws {
            try containerWrapper
                .keyedContainer
                .decode(T.self, forKey: .key(name))
        }
    }

    public func `as`<T: Decodable>(_ type: T.Type) throws -> T {
        switch containerWrapper {
        case let .decoder(decoder):
            return try decoder.singleValueContainer().decode(T.self)

        case let .keyedContainer(container, key):
            return try container.decode(T.self, forKey: key)

        case var .unkeyedContainer(container):
            return try container.decode(T.self)
        }
    }

    public func map<T>(_ transform: (JSON) throws -> T) throws -> [T] {
        try compactMap(transform)
    }

    public func flatMap<T>(_ transform: (JSON) throws -> JSON) throws -> [T] where T: Decodable {
        try compactMap {
            try $0.as(T.self)
        }
    }

    public func compactMap<T>(_ transform: (JSON) throws -> T?) throws -> [T] {
        var container = try containerWrapper
            .unkeyedContainer

        var result: [T] = []
        result.reserveCapacity(container.count ?? 3)
        while !container.isAtEnd {
            if let element = try transform(JSON(containerWrapper: .unkeyedContainer(container))) {
                result.append(element)
            }
            try container.skip(1)
        }
        return result
    }

    public func compactMap<T: Decodable>(_ type: T.Type = T.self) throws -> [T] {
        try compactMap { try? $0.as(T.self) }
    }

    public var bool: Bool { get throws { try self.as(Bool.self) } }
    public var float: Float { get throws { try self.as(Float.self) } }
    public var double: Double { get throws { try self.as(Double.self) } }
    public var string: String { get throws { try self.as(String.self) } }
    public var int: Int { get throws { try self.as(Int.self) } }
    public var int8: Int8 { get throws { try self.as(Int8.self) } }
    public var int16: Int16 { get throws { try self.as(Int16.self) } }
    public var int32: Int32 { get throws { try self.as(Int32.self) } }
    public var int64: Int64 { get throws { try self.as(Int64.self) } }
    public var uint: UInt { get throws { try self.as(UInt.self) } }
    public var uint8: UInt8 { get throws { try self.as(UInt8.self) } }
    public var uint16: UInt16 { get throws { try self.as(UInt16.self) } }
    public var uint32: UInt32 { get throws { try self.as(UInt32.self) } }
    public var uint64: UInt64 { get throws { try self.as(UInt64.self) } }
}
