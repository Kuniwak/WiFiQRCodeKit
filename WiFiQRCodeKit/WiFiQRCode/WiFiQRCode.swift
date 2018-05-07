public struct WiFiQRCode: Equatable {
    public let ssid: SSID
    public let encryptionType: WiFiQRCode.EncryptionType
    public let isHidden: Bool


    public init(ssid: SSID, encryptionType: WiFiQRCode.EncryptionType, isHidden: Bool) {
        self.ssid = ssid
        self.encryptionType = encryptionType
        self.isHidden = isHidden
    }
}
