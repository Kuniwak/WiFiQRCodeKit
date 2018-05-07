public func parse(text: String) -> ParsingResult<WiFiQRCode, ParsingFailureReason> {
    let candidates = wifiQRCodeContent(Substring(text)).map { $0.0 }

    guard candidates.count < 2 else {
        return .failed(because: .ambiguousError)
    }

    guard let result = candidates.first else {
        return .failed(because: .syntaxError)
    }

    switch result {
    case .failed(because: let semanticProblem):
        return .failed(because: .semanticProblem(semanticProblem))
    case .success(let wiFiQrCode):
        return .success(wiFiQrCode)
    }
}


let wifiQRCodeContent = sequence(
    string(expected: "WIFI:"),
    sequence(
        meCardFields,
        character(expected: terminator)
    )
) >>- { tuple -> Parser<ParsingResult<WiFiQRCode, SemanticProblem>> in
    let (_, (fields, _)) = tuple
    return result(createWiFiQRCode(from: fields))
}


func createWiFiQRCode(from fields: [String: String]) -> ParsingResult<WiFiQRCode, SemanticProblem> {
    switch (createSSID(from: fields), createEncryptionType(from: fields), createHiddenFlag(from: fields)) {
    case (.success(let ssid), .success(let encryptionType), .success(let isHidden)):
        return .success(WiFiQRCode(ssid: ssid, encryptionType: encryptionType, isHidden: isHidden))
    case (.failed(because: let reason), _, _):
        return .failed(because: reason)
    case (_, .failed(because: let reason), _):
        return .failed(because: reason)
    case (_, _, .failed(because: let reason)):
        return .failed(because: reason)
    }
}


func createHiddenFlag(from fields: [String: String]) -> ParsingResult<Bool, SemanticProblem> {
    if let hiddenSSIDText = fields[hiddenHeaderName]?.lowercased() {
        switch hiddenSSIDText {
        case "true":
            return .success(true)
        case "false":
            return .success(false)
        default:
            return .failed(because: .invalidSSIDVisibility(hiddenSSIDText))
        }
    }
    else {
        return .success(false)
    }
}


func createSSID(from fields: [String: String]) -> ParsingResult<SSID, SemanticProblem> {
    guard let ssidText = fields[ssidHeaderName] else {
        return .failed(because: .missingSSID)
    }

    switch SSID.validate(text: ssidText) {
    case .invalid(because: let reason):
        return .failed(because: .invalidSSID(reason))
    case .valid(content: let ssid):
        return .success(ssid)
    }
}


func createEncryptionType(from fields: [String: String]) -> ParsingResult<WiFiQRCode.EncryptionType, SemanticProblem> {
    guard let encryptionTypeText = fields[encryptionTypeHeaderName] else {
        return .success(.none)
    }

    switch encryptionTypeText.lowercased() {
    case "wep":
        guard let passwordText = fields[passwordHeaderName] else {
            return .failed(because: .missingPassword)
        }

        switch Password.validate(passwordText: passwordText) {
        case .invalid(because: let reason):
            return .failed(because: .invalidPassword(reason))
        case .valid(content: let password):
            return .success(.wep(password))
        }

    case "wpa":
        guard let passwordText = fields[passwordHeaderName] else {
            return .failed(because: .missingPassword)
        }

        switch Password.validate(passwordText: passwordText) {
        case .invalid(because: let reason):
            return .failed(because: .invalidPassword(reason))
        case .valid(content: let password):
            return .success(.wpa(password))
        }

    case "nopass":
        return .success(.none)

    default:
        return .failed(because: .unknownEncryptionType(encryptionTypeText))
    }
}


public enum ParsingResult<C, E> {
    case success(C)
    case failed(because: E)
}


extension ParsingResult: Equatable where C: Equatable, E: Equatable {
    public static func ==(lhs: ParsingResult<C, E>, rhs: ParsingResult<C, E>) -> Bool {
        switch (lhs, rhs) {
        case (.success(let l), .success(let r)):
            return l == r
        case (.failed(because: let l), .failed(because: let r)):
            return l == r
        default:
            return false
        }
    }
}


public enum ParsingFailureReason {
    case syntaxError
    case ambiguousError
    case semanticProblem(SemanticProblem)
}


extension ParsingFailureReason: Equatable {
    public static func ==(lhs: ParsingFailureReason, rhs: ParsingFailureReason) -> Bool {
        switch (lhs, rhs) {
        case (.syntaxError, .syntaxError), (.ambiguousError, .ambiguousError):
            return true
        case (.semanticProblem(let l), .semanticProblem(let r)):
            return l == r
        default:
            return false
        }
    }
}


public enum SemanticProblem {
    case missingSSID
    case invalidSSID(SSID.FailureReason)
    case missingPassword
    case invalidPassword(Password.FailureReason)
    case unknownEncryptionType(String)
    case invalidSSIDVisibility(String)
}


extension SemanticProblem: Equatable {
    public static func ==(lhs: SemanticProblem, rhs: SemanticProblem) -> Bool {
        switch (lhs, rhs) {
        case (.missingSSID, .missingSSID), (.missingPassword, .missingPassword):
            return true
        case (.invalidSSID(let l), .invalidSSID(let r)):
            return l == r
        case (.invalidPassword(let l), .invalidPassword(let r)):
            return l == r
        case (.unknownEncryptionType(let l), .unknownEncryptionType(let r)):
            return l == r
        case (.invalidSSIDVisibility(let l), .invalidSSIDVisibility(let r)):
            return l == r
        default:
            return false
        }
    }
}
