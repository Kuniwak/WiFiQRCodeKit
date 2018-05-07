extension WiFiQRCode {
    public static func validate(
        ssid ssidText: String,
        encryptionType: WiFiQRCode.EncryptionType,
        isHidden: Bool
    ) -> ValidationResult<WiFiQRCode, ValidationError> {
        let result = SSID.validate(text: ssidText)

        switch result {
        case .valid(content: let ssid):
            return .valid(content: WiFiQRCode(
                ssid: ssid,
                encryptionType: encryptionType,
                isHidden: isHidden
            ))
        case .invalid(let ssidError):
            return .invalid(because: .invalidSsid(ssidError))
        }
    }


    public enum ValidationError: Error {
        case invalidSsid(SSID.FailureReason)
    }
}