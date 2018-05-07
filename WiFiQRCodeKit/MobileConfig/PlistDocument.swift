import Foundation



public struct PlistDocument: Equatable {
    public let root: [String: PlistSerializable]


    public init(root: [String: PlistSerializable]) {
        self.root = root
    }


    public func serializeAsObject() -> [String: Any] {
        return createPlistSerializable(from: self.root)
    }


    public func serializeAsPlistXML() -> SerializationResult {
        do {
            let data = try PropertyListSerialization.data(
                fromPropertyList: self.serializeAsObject(),
                format: .xml,
                options: 0
            )
            return .success(data)
        }
        catch {
            return .failed(because: .unspecified(debugInfo: "\(error)"))
        }
    }


    public enum SerializationResult {
        case success(Data)
        case failed(because: SerializationFailureReason)


        public var data: Data? {
            switch self {
            case .success(let data):
                return data
            case .failed:
                return nil
            }
        }
    }


    public enum SerializationFailureReason: Equatable {
        case unspecified(debugInfo: String)
    }
}


internal func createPlistSerializable(from raw: [PlistSerializable]) -> [Any] {
    return raw.map(createPlistSerializable)
}


internal func createPlistSerializable(from raw: [String: PlistSerializable]) -> [String: Any] {
    return raw
        .sorted { (a, b) in a.key > b.key }
        .reduce(into: [String: Any]()) { (result, entry) in
            let (key, value) = entry
            result[key] = createPlistSerializable(from: value)
        }
}


internal func createPlistSerializable(from raw: PlistSerializable) -> Any {
    switch raw {
    case .bool(let bool):
        return bool
    case .string(let string):
        return string
    case .int(let int):
        return int
    case .float(let float):
        return float
    case .date(let date):
        return date
    case .array(let array):
        return createPlistSerializable(from: array)
    case .dictionary(let dictionary):
        return createPlistSerializable(from: dictionary)
    }
}
