import Foundation



public indirect enum PlistSerializable: Equatable {
    case bool(Bool)
    case string(String)
    case int(Int)
    case float(Float)
    case date(Date)
    case array([PlistSerializable])
    case dictionary([String: PlistSerializable])


    public static func from(_ any: Any) -> Result {
        if let bool = any as? Bool {
            return .success(.from(bool))
        }

        if let string = any as? String {
            return .success(.from(string))
        }

        if let int = any as? Int {
            return .success(.from(int))
        }

        if let float = any as? Float {
            return .success(.from(float))
        }

        if let date = any as? Date {
            return .success(.from(date))
        }

        if let array = any as? [Any] {
            return PlistSerializable.from(array)
        }

        if let dictionary = any as? [String: Any] {
            return PlistSerializable.from(dictionary)
        }

        return .failed(because: .unsupportedType(debugInfo: "\(type(of: any))"))
    }


    public static func from(_ bool: Bool) -> PlistSerializable {
        return .bool(bool)
    }


    public static func from(_ string: String) -> PlistSerializable {
        return .string(string)
    }


    public static func from(_ int: Int) -> PlistSerializable {
        return .int(int)
    }


    public static func from(_ float: Float) -> PlistSerializable {
        return .float(float)
    }


    public static func from(_ date: Date) -> PlistSerializable {
        return .date(date)
    }


    public static func from(_ array: [PlistSerializable]) -> PlistSerializable {
        return .array(array)
    }


    public static func from(_ array: [Any]) -> Result {
        var result = [PlistSerializable]()

        for x in array {
            switch PlistSerializable.from(x) {
            case .success(let plistSerializable):
                result.append(plistSerializable)
            case .failed(because: let reason):
                return .failed(because: reason)
            }
        }

        return .success(.from(result))
    }


    public static func from(_ dictionary: [String: PlistSerializable]) -> PlistSerializable {
        return .dictionary(dictionary)
    }


    public static func from(_ dictionary: [String: Any]) -> Result {
        var result = [String: PlistSerializable]()

        for (key, value) in dictionary {
            switch PlistSerializable.from(value) {
            case .success(let plistSerializable):
                result[key] = plistSerializable
            case .failed(because: let reason):
                return .failed(because: reason)
            }
        }

        return .success(.from(result))
    }


    public enum Result: Equatable {
        case success(PlistSerializable)
        case failed(because: FailureReason)


        public var plistSerializable: PlistSerializable? {
            switch self {
            case .success(let x):
                return x
            case .failed:
                return nil
            }
        }
    }


    public enum FailureReason: Equatable {
        case unsupportedType(debugInfo: String)
    }
}
