import Foundation

private struct UUIDCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) { nil }

    init(_ uuid: UUID) {
        self.stringValue = uuid.uuidString
    }
}

extension UUID: @retroactive CodingKeyRepresentable {
    public var codingKey: CodingKey {
        UUIDCodingKey(self)
    }

    public init?<T: CodingKey>(codingKey: T) {
        guard let uuid = UUID(uuidString: codingKey.stringValue) else {
            return nil
        }
        self = uuid
    }
}
