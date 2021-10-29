@dynamicMemberLookup
public struct JSON: Decodable {
    typealias KeyedContainer = KeyedDecodingContainer<Key>
    typealias UnkeyedContainer = UnkeyedDecodingContainer

    enum ContainerWrapper {
        case decoder(Decoder)
        case keyedContainer(KeyedContainer, Key)
        case unkeyedContainer(UnkeyedContainer)

        var keyedContainer: () throws -> KeyedContainer {
            get {
                {
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
        }

        var unkeyedContainer: () throws -> UnkeyedContainer {
            get {
                {
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
    }

    private let containerWrapper: () throws -> ContainerWrapper

    public init(from decoder: Decoder) throws {
        self.init(containerWrapper: { .decoder(decoder) })
    }

    private init(containerWrapper: @escaping () throws -> ContainerWrapper) {
        self.containerWrapper = containerWrapper
    }

    public subscript(_ key: String) -> JSON {
        get {
            self[dynamicMember: key]
        }
    }

    public subscript(dynamicMember name: String) -> JSON {
        get {
            JSON(containerWrapper: { try .keyedContainer(containerWrapper().keyedContainer(), .key(name)) })
        }
    }

    public subscript(_ index: Int) -> JSON {
        get {
            JSON(containerWrapper: { try .unkeyedContainer(
                containerWrapper()
                    .unkeyedContainer()
                    .skipped(index - 1)
            )})
        }
    }

    public subscript<T: Decodable>(_ index: Int) -> () throws -> T {
        get {
            {
                var container = try containerWrapper()
                    .unkeyedContainer()
                    .skipped(index - 1)
                return try container.decode(T.self)
            }
        }
    }

    public subscript<T: Decodable>(_ name: String) -> () throws -> T {
        get {
            { try self[dynamicMember: name]() }
        }
    }

    public subscript<T: Decodable>(dynamicMember name: String) -> () throws -> T {
        get {
            {
                try containerWrapper()
                    .keyedContainer()
                    .decode(T.self, forKey: .key(name))
            }
        }
    }

    public func `as`<T: Decodable>(_ type: T.Type) throws -> T {
        switch try containerWrapper() {
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
        var container = try containerWrapper()
            .unkeyedContainer()

        var result: [T] = []
        result.reserveCapacity(container.count ?? 3)
        while !container.isAtEnd {
            let json = JSON(containerWrapper: { .unkeyedContainer(container) })
            if let element = try transform(json) {
                result.append(element)
            }
            try container.skip(1)
        }
        return result
    }

    public var bool: () throws -> Bool { { try self.as(Bool.self) } }
    public var float: () throws -> Float { { try self.as(Float.self) } }
    public var double: () throws -> Double { { try self.as(Double.self) } }
    public var string: () throws -> String { { try self.as(String.self) } }
    public var int: () throws -> Int { { try self.as(Int.self) } }
    public var int8: () throws -> Int8 { { try self.as(Int8.self) } }
    public var int16: () throws -> Int16 { { try self.as(Int16.self) } }
    public var int32: () throws -> Int32 { { try self.as(Int32.self) } }
    public var int64: () throws -> Int64 { { try self.as(Int64.self) } }
    public var uint: () throws -> UInt { { try self.as(UInt.self) } }
    public var uint8: () throws -> UInt8 { { try self.as(UInt8.self) } }
    public var uint16: () throws -> UInt16 { { try self.as(UInt16.self) } }
    public var uint32: () throws -> UInt32 { { try self.as(UInt32.self) } }
    public var uint64: () throws -> UInt64 { { try self.as(UInt64.self) } }
}
