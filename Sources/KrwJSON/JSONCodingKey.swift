extension JSON {
    enum Key: CodingKey {
        case key(String)
        case index(Int)

        init?(stringValue: String) {
            self = .key(stringValue)
        }

        init?(intValue: Int) {
            self = .index(intValue)
        }

        var stringValue: String {
            switch self {
            case let .index(index):
                return "\(index)"
            case let .key(name):
                return name
            }
        }

        var intValue: Int? {
            switch self {
            case let .index(index):
                return index
            case .key:
                return nil
            }
        }
    }
}
