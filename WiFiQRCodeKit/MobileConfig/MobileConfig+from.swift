import Foundation



extension MobileConfig {
    public static func from(
        wiFiQRCode: WiFiQRCode,
        organization: OrganizationName,
        identifier: PayloadIdentifier? = nil,
        description: String? = nil,
        displayName: DisplayName? = nil,
        consentText: ConsentText? = nil
    ) -> MobileConfig {
        let wiFiUUID = UUID()

        return MobileConfig(
            contents: [
                MobileConfig.PayloadContent.wiFi(.init(
                    version: .init(version: 1),
                    identifier: .from(
                        uuid: wiFiUUID,
                        type: .wiFi
                    ),
                    uuid: wiFiUUID,
                    displayName: DisplayName.wiFi,
                    description: description ?? "Configures Wi-Fi settings",
                    organization: organization,
                    ssid: wiFiQRCode.ssid,
                    isHiddenNetwork: wiFiQRCode.isHidden,
                    isAutoJoinEnabled: true,
                    encryptionType: .from(encryptionType: wiFiQRCode.encryptionType),
                    hotspotType: nil,
                    proxy: nil,
                    isCaptiveBypassEnabled: nil,
                    qosMarkingPolicy: nil
                ))
            ],
            description: description ?? "Configures Wi-Fi settings",
            displayName: displayName ?? DisplayName(displayName: "Wi-Fi"),
            expired: nil,
            identifier: identifier ?? MobileConfig.PayloadIdentifier.from(ssid: wiFiQRCode.ssid),
            organization: organization,
            uuid: UUID(),
            isRemovalDisallowed: false,
            scope: nil,
            autoRemoving: nil,
            consentText: consentText
        )
    }
}


fileprivate extension MobileConfig.PayloadIdentifier {
    fileprivate static func from(ssid: SSID) -> MobileConfig.PayloadIdentifier {
        return .init(identifier: ssid.octetString)
    }
}


fileprivate extension MobileConfig.WiFi.EncryptionType {
    fileprivate static func from(encryptionType: WiFiQRCode.EncryptionType) -> MobileConfig.WiFi.EncryptionType {
        switch encryptionType {
        case .none:
            return .none
        case .wep(let password):
            return .wep(password)
        case .wpa(let password):
            // > WPA specifies WPA only; WPA2 applies to both encryption types.
            // > https://developer.apple.com/library/content/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010206-CH1-SW30
            return .wpa2(password)
        }
    }
}