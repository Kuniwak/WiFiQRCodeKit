import Foundation



public struct WiFiMobileConfig: Equatable {
    // The payload type. The payload types are described in Payload-Specific Property Keys.
    public var type: MobileConfig.PayloadType {
        return .wiFi
    }

    // The version number of the individual payload.
    //
    // A profile can consist of payloads with different version numbers.
    // For example, changes to the VPN software in iOS might introduce a new payload version to
    // support additional features, but Mail payload versions would not necessarily change in the same release.
    public let version: MobileConfig.PayloadVersion

    // A reverse-DNS-style identifier for the specific payload. It is usually the same identifier as
    // the root-level PayloadIdentifier value with an additional component appended.
    public let identifier: MobileConfig.PayloadIdentifier

    // A globally unique identifier for the payload. The actual content is unimportant, but it must be globally unique.
    // In macOS, you can use uuidgen to generate reasonable UUIDs.
    public let uuid: UUID

    // A human-readable name for the profile payload. This name is displayed on the Detail screen.
    // It does not have to be unique.
    public let displayName: MobileConfig.DisplayName

    // Optional. A description of the profile, shown on the Detail screen for the profile.
    // This should be descriptive enough to help the user decide whether to install the profile.
    public let description: String?

    // Optional. A human-readable string containing the name of the organization that provided the profile.
    // The payload organization for a payload need not match the payload organization in the enclosing profile.
    public let organization: MobileConfig.OrganizationName?

    // SSID of the Wi-Fi network to be used.
    // In iOS 7.0 and later, this is optional if a DomainName value is provided
    public let ssid: SSID

    // Besides SSID, the device uses information such as broadcast type and encryption type to differentiate a network.
    // By default (false), it is assumed that all configured networks are open or broadcast.
    // To specify a hidden network, must be true.
    public var isHiddenNetwork: Bool

    // Optional. Default true. If true, the network is auto-joined. If false,
    // the user has to tap the network name to join it.
    //
    // Availability: Available in iOS 5.0 and later and in all versions of macOS.
    public let isAutoJoinEnabled: Bool?

    // The possible values are WEP, WPA, WPA2, Any, and None. WPA specifies WPA only; WPA2 applies to both encryption types.
    // Make sure that these values exactly match the capabilities of the network access point.
    // If you're unsure about the encryption type, or would prefer that it apply to all encryption types, use the value Any.
    //
    // Availability: Key available in iOS 4.0 and later and in all versions of macOS. The None value is available in iOS 5.0 and later and the WPA2 value is available in iOS 8.0 and later.
    public let encryptionType: EncryptionType

    // Optional. Default false. If true, the network is treated as a hotspot.
    //
    // Availability: Available in iOS 7.0 and later and in macOS 10.9 and later.
    public let hotspotType: HotspotType?

    // Optional. Valid values are None, Manual, and Auto.
    //
    // Availability: Available in iOS 5.0 and later and on all versions of macOS.
    public let proxy: ProxyConfiguration?

    // Optional. If set to true, Captive Network detection will be bypassed when the device connects to the network.
    // Defaults to false.
    //
    // Availability: Available in iOS 10.0 and later.
    public let isCaptiveBypassEnabled: Bool?

    // Optional. When this dictionary is not present for a Wi-Fi network, all apps are whitelisted to use
    // L2 and L3 marking when the Wi-Fi network supports Cisco QoS fast lane. When present in the Wi-Fi payload,
    // the QoSMarkingPolicy dictionary should contain the list of apps that are allowed to benefit from
    // L2 and L3 marking. For dictionary keys, see the table below.
    //
    // Availability: Available in iOS 10.0 and later and in macOS 10.13 and later.
    public let qosMarkingPolicy: QoSMarkingPolicy?


    // TODO: EncryptionType for Enterprise is not supported. If you want to use it, you can send PR for it.


    public init(
        version: MobileConfig.PayloadVersion,
        identifier: MobileConfig.PayloadIdentifier,
        uuid: UUID,
        displayName: MobileConfig.DisplayName,
        description: String,
        organization: MobileConfig.OrganizationName,
        ssid: SSID,
        isHiddenNetwork: Bool,
        isAutoJoinEnabled: Bool?,
        encryptionType: EncryptionType,
        hotspotType: HotspotType?,
        proxy: ProxyConfiguration?,
        isCaptiveBypassEnabled: Bool?,
        qosMarkingPolicy: QoSMarkingPolicy?
    ) {
        self.version = version
        self.identifier = identifier
        self.uuid = uuid
        self.displayName = displayName
        self.description = description
        self.organization = organization
        self.ssid = ssid
        self.isHiddenNetwork = isHiddenNetwork
        self.isAutoJoinEnabled = isAutoJoinEnabled
        self.encryptionType = encryptionType
        self.hotspotType = hotspotType
        self.proxy = proxy
        self.isCaptiveBypassEnabled = isCaptiveBypassEnabled
        self.qosMarkingPolicy = qosMarkingPolicy
    }


    public var serializableRepresentation: PlistSerializable {
        var result = [String: PlistSerializable]()

        result[MobileConfig.CommonKey.type] = self.type.serializableRepresentation
        result[MobileConfig.CommonKey.version] = self.version.serializableRepresentation
        result[MobileConfig.CommonKey.identifier] = self.identifier.serializableRepresentation
        result[MobileConfig.CommonKey.uuid] = .from(self.uuid.uuidString)
        result[MobileConfig.CommonKey.displayName] = self.displayName.serializableRepresentation

        if let description = self.description {
            result[MobileConfig.CommonKey.description] = .from(description)
        }

        if let organization = self.organization {
            result[MobileConfig.CommonKey.organization] = organization.serializableRepresentation
        }

        result[WiFiSpecificKey.ssid] = self.ssid.serializableRepresentation
        result[WiFiSpecificKey.hiddenNetwork] = .from(self.isHiddenNetwork)

        if let isAutoJoinEnabled = self.isAutoJoinEnabled {
            result[WiFiSpecificKey.autoJoin] = .from(isAutoJoinEnabled)
        }

        result.merge(self.encryptionType.serializableRepresentationContent) { (a, b) in b }

        if let hotspotType = self.hotspotType {
            switch hotspotType {
            case .legacy:
                result[WiFiSpecificKey.isHotspot] = .from(true)
            }
        }

        if let proxy = self.proxy {
            result.merge(proxy.serializableRepresentationContent) { (a, b) in b }
        }

        if let isCaptiveBypassEnabled = self.isCaptiveBypassEnabled {
            result[WiFiSpecificKey.captiveBypass] = .from(isCaptiveBypassEnabled)
        }

        if let qosMarkingPolicy = self.qosMarkingPolicy {
            result[WiFiSpecificKey.qosMarkingPolicy] = qosMarkingPolicy.serializableRepresentation
        }

        return .from(result)
    }


    public enum ProxyConfiguration: Equatable {
        case none
        case manual(Manual)
        case auto(Auto)


        public var serializableRepresentationContent: [String: PlistSerializable] {
            switch self {
            case .none:
                return [WiFiSpecificKey.proxyType: .from("None")]

            case .manual(let manual):
                var result = [String: PlistSerializable]()

                result[WiFiSpecificKey.proxyType] = .from("Manual")
                result.merge(manual.serializableRepresentationContent) { (a, b) in b }

                return result

            case .auto(let auto):
                var result = [String: PlistSerializable]()

                result[WiFiSpecificKey.proxyType] = .from("Auto")
                result.merge(auto.serializableRepresentationContent) { (a, b) in b }

                return result
            }
        }


        public struct Manual: Equatable {
            public let server: ServerName
            public let port: Port
            public let authentication: Authentication?


            public init(server: ServerName, port: Port, authentication: Authentication?) {
                self.server = server
                self.port = port
                self.authentication = authentication
            }


            public var serializableRepresentationContent: [String: PlistSerializable] {
                var result = [String: PlistSerializable]()

                result[ProxySpecificKey.proxyServer] = self.server.serializableRepresentation
                result[ProxySpecificKey.proxyServerPort] = self.port.serializableRepresentation

                if let authentication = self.authentication {
                    result[ProxySpecificKey.proxyUsername] = authentication.userName.serializableRepresentation
                    result[ProxySpecificKey.proxyPassword] = authentication.password.serializableRepresentation
                }

                return result
            }


            public struct Authentication: Equatable {
                public let userName: UserName
                public let password: Password


                public init(userName: UserName, password: Password) {
                    self.userName = userName
                    self.password = password
                }


                public struct UserName: Equatable {
                    fileprivate let name: String


                    public init(userName name: String) {
                        self.name = name
                    }


                    public var serializableRepresentation: PlistSerializable {
                        return .from(self.name)
                    }
                }


                public struct Password: Equatable {
                    fileprivate let text: String


                    public init(password text: String) {
                        self.text = text
                    }


                    public var serializableRepresentation: PlistSerializable {
                        return .from(self.text)
                    }
                }
            }
        }


        public struct Auto: Equatable {
            public let pacURL: URL
            public let isPACFallbackAllowed: Bool?


            public var serializableRepresentationContent: [String: PlistSerializable] {
                var result = [String: PlistSerializable]()

                result[ProxySpecificKey.proxyPACURL] = .from(self.pacURL.absoluteString)

                if let isPACFallbackAllowed = self.isPACFallbackAllowed {
                    result[ProxySpecificKey.proxyPACFallbackAllowed] = .from(isPACFallbackAllowed)
                }

                return result
            }
        }


        public enum ProxySpecificKey {
            public static let proxyServer = "ProxyServer"
            public static let proxyServerPort = "ProxyServerPort"
            public static let proxyUsername = "ProxyUsername"
            public static let proxyPassword = "ProxyPassword"
            public static let proxyPACURL = "ProxyPACURL"
            public static let proxyPACFallbackAllowed = "ProxyPACFallbackAllowed"
        }
    }


    public enum EncryptionType: Equatable {
        case none
        case wep(Password)
        case wpa(Password)
        case wpa2(Password /* NOT IMPLEMENTED: , EAPClientConfiguration? */)
        case any(Password?)


        public var serializableRepresentationContent: [String: PlistSerializable] {
            switch self {
            case .none:
                return [WiFiSpecificKey.encryptionType: .from("None")]
            case .wep(let password):
                return [
                    WiFiSpecificKey.encryptionType: .from("WEP"),
                    WiFiSpecificKey.password: .from(password.text)
                ]
            case .wpa(let password):
                return [
                    WiFiSpecificKey.encryptionType: .from("WPA"),
                    WiFiSpecificKey.password: .from(password.text)
                ]
            case .wpa2(let password):
                return [
                    WiFiSpecificKey.encryptionType: .from("WPA2"),
                    WiFiSpecificKey.password: .from(password.text)
                ]
            case .any(.none):
                return [WiFiSpecificKey.encryptionType: .from("Any")]
            case .any(.some(let password)):
                return [
                    WiFiSpecificKey.encryptionType: .from("Any"),
                    WiFiSpecificKey.password: .from(password.text)
                ]
            }
        }
    }


    public enum HotspotType: Equatable {
        case legacy
        // NOT IMPLEMENTED: case passpoint(Passpoint)
        // Because it require to implement EAP (it is huge class, so it is not implemented yet).
    }


    public struct QoSMarkingPolicy: Equatable {
        public let whitelistedAppIdentifiers: [BundleIdentifier]?
        public let isAppleAudioVideoCallsAllowed: Bool?
        public let isEnabled: Bool?


        public init(
            whitelistedAppIdentifiers: [BundleIdentifier]?,
            isAppleAudioVideoCallsAllowed: Bool?,
            isEnabled: Bool?
        ) {
            self.whitelistedAppIdentifiers = whitelistedAppIdentifiers
            self.isAppleAudioVideoCallsAllowed = isAppleAudioVideoCallsAllowed
            self.isEnabled = isEnabled
        }


        public var serializableRepresentation: PlistSerializable {
            var result = [String: PlistSerializable]()

            if let bundleIds = self.whitelistedAppIdentifiers, !bundleIds.isEmpty {
                result["QoSMarkingWhitelistedAppIdentifiers"] = .from(
                    bundleIds.map { $0.serializableRepresentation }
                )
            }

            if let isAppleAudioVideoCallsAllowed = self.isAppleAudioVideoCallsAllowed {
                result["QoSMarkingAppleAudioVideoCalls"] = .from(isAppleAudioVideoCallsAllowed)
            }

            if let isEnabled = self.isEnabled {
                result["QoSMarkingEnabled"] = .from(isEnabled)
            }

            return .from(result)
        }
    }


    public struct ServerName: Hashable {
        fileprivate let name: String


        public init(serverName name: String) {
            self.name = name
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.name)
        }
    }


    public struct Port: Hashable {
        fileprivate let number: Int


        public init(port number: Int) {
            self.number = number
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.number)
        }
    }


    public struct BundleIdentifier: Hashable {
        fileprivate let text: String


        public init(bundleIdentifier text: String) {
            self.text = text
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.text)
        }
    }


    public enum WiFiSpecificKey {
        public static let ssid = "SSID_STR"
        public static let hiddenNetwork = "HIDDEN_NETWORK"
        public static let autoJoin = "AutoJoin"
        public static let encryptionType = "EncryptionType"
        public static let password = "Password"
        public static let isHotspot = "IsHotspot"
        public static let domainName = "DomainName"
        public static let serviceProviderRoamingEnabled = "ServiceProviderRoamingEnabled"
        public static let roamingConsortiumOIs = "RoamingConsortiumOIs"
        public static let naiRealmNames = "NAIRealmNames"
        public static let mccAndMncs = "MCCAndMNCs"
        public static let displayedOperatorName = "DisplayedOperatorName"
        public static let proxyType = "ProxyType"
        public static let captiveBypass = "CaptiveBypass"
        public static let qosMarkingPolicy = "QoSMarkingPolicy"
    }
}


extension WiFiMobileConfig.BundleIdentifier: Comparable {
    public static func <(
        lhs: WiFiMobileConfig.BundleIdentifier,
        rhs: WiFiMobileConfig.BundleIdentifier
    ) -> Bool {
        return lhs.text < rhs.text
    }
}
