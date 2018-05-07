public extension WiFiQRCode {
    public enum EncryptionType: Equatable {
        case none
        case wep(Password)
        case wpa(Password)


        public var text: String {
            switch self {
            case .none:
                return "nopass"
            case .wep:
                return "WEP"
            case .wpa:
                return "WPA"
            }
        }
    }
}
