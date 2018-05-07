public extension Password {
    public static func validate(passwordText: String) -> ValidationResult<Password, FailureReason> {
        guard !passwordText.isEmpty else {
            return .invalid(because: .empty)
        }

        return .valid(content: Password(passwordText))
    }


    public enum FailureReason: Error {
        case empty
    }
}