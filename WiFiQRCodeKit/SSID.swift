public struct SSID: Hashable {
    public let octetString: String


    public init(_ octetString: String) {
        self.octetString = octetString
    }


    public var serializableRepresentation: PlistSerializable {
        return .from(self.octetString)
    }
}
