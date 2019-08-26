public extension Password {
    static func validate(passwordText: String) -> ValidationResult<Password, FailureReason> {
        guard !passwordText.isEmpty else {
            return .invalid(because: .empty)
        }

        return .valid(content: Password(passwordText))
    }


    enum FailureReason: Error {
        case empty
    }
}
