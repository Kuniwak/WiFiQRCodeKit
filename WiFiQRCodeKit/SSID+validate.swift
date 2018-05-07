extension SSID {
    public static func validate(text: String) -> ValidationResult<SSID, FailureReason> {
        guard text.utf8CString.count <= 32 else {
            return .invalid(because: .greaterThan32Bytes)
        }

        return .valid(content: SSID(text))
    }


    public enum FailureReason: Error, Equatable {
        case greaterThan32Bytes
    }
}
