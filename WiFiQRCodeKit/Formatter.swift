import Foundation



public func format(wiFiQRCode: WiFiQRCode) -> String {
    let meCardFields = getMeCardFields(from: wiFiQRCode)
        .map { field in "\(field.0):\(field.1);" }
        .joined(separator: "")

    return "WIFI:\(meCardFields);"
}


private func getMeCardFields(from wiFiQrCode: WiFiQRCode) -> [(String, String)] {
    var result = [("S", escapeMeCardSpecialCharacters(wiFiQrCode.ssid.octetString))]

    if wiFiQrCode.isHidden {
        result.append(("H", "true"))
    }

    switch wiFiQrCode.encryptionType {
    case .none:
        break
    case .wep(password: let password):
        result.append(("T", "WEP"))
        result.append(("P", escapeMeCardSpecialCharacters(password.text)))
    case .wpa(password: let password):
        result.append(("T", "WPA"))
        result.append(("P", escapeMeCardSpecialCharacters(password.text)))
    }

    return result
}


private func escapeMeCardSpecialCharacters(_ text: String) -> String {
    return text.replacingOccurrences(
        of: "([\\\\;,:\"])", // NOTE: This string recognized as /([\\;,:"])/
        with: "\\\\$1", // NOTE: This string recognized as /\\$1/
        options: .regularExpression,
        range: text.range(of: text)
    )
}
