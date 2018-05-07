import Foundation



public struct MobileConfig: Equatable {
    // XXX: For compatible.
    typealias WiFi = WiFiMobileConfig

    // Optional. Array of payload dictionaries. Not present if IsEncrypted is true.
    public let contents: [PayloadContent]?

    // Optional. A description of the profile, shown on the Detail screen for the profile.
    // This should be descriptive enough to help the user decide whether to install the profile.
    public let description: String?

    // Optional. A human-readable name for the profile. This value is displayed on the Detail screen.
    // It does not have to be unique.
    public let displayName: DisplayName?

    // Optional. A date on which a profile is considered to have expired and can be updated over the air.
    // This key is only used if the profile is delivered via over-the-air profile delivery.
    public let expired: Date?

    // A reverse-DNS style identifier (com.example.myprofile, for example) that identifies the profile.
    // This string is used to determine whether a new profile should replace an existing one or should be added.
    public let identifier: PayloadIdentifier

    // Optional. A human-readable string containing the name of the organization that provided the profile.
    // The payload organization for a payload need not match the payload organization in the enclosing profile.
    public let organization: OrganizationName?

    // A globally unique identifier for the profile. The actual content is unimportant, but it must be globally unique.
    // In macOS, you can use uuidgen to generate reasonable UUIDs.
    public let uuid: UUID

    // Optional. Supervised only. If present and set to true, the user cannot delete the profile (unless
    // the profile has a removal password and the user provides it).
    public let isRemovalDisallowed: Bool?

    // The only supported value is Configuration.
    public var type: PayloadType {
        return .mobileConfig
    }

    // The version number of the profile format. This describes the version of the configuration profile as a whole,
    // not of the individual profiles within it.
    //
    // Currently, this value should be 1.
    public let version = PayloadVersion(version: 1)

    // Optional. Determines if the profile should be installed for the system or the user. In many cases,
    // it determines the location of the certificate items, such as keychains.
    // Though it is not possible to declare different payload scopes, payloads, like VPN,
    // may automatically install their items in both scopes if needed.
    //
    // Legal values are System and User, with User as the default value.
    //
    // Availability: Available in macOS 10.7 and later.
    public let scope: PayloadScope?

    // Optional. The date on which the profile will be automatically removed.
    // Optional. Number of seconds until the profile is automatically removed. If the RemovalDate keys is present,
    // whichever field yields the earliest date will be used.
    public let autoRemoving: AutoRemovingConfiguration?

    // Optional. A dictionary containing these keys and values:
    //
    // For each language in which a consent or license agreement is available,
    // a key consisting of the IETF BCP 47 identifier for that language (for example, en or jp) and
    // a value consisting of the agreement localized to that language. The agreement is displayed in a dialog to
    // which the user must agree before installing the profile.
    // The optional key default with its value consisting of the unlocalized agreement (usually in en).
    // The system chooses a localized version in the order of preference specified by the user (macOS) or
    // based on the user’s current language setting (iOS). If no exact match is found, the default localization is used.
    // If there is no default localization, the en localization is used. If there is no en localization,
    // then the first available localization is used.
    //
    // You should provide a default value if possible. No warning will be displayed if the user’s locale does not
    // match any localization in the ConsentText dictionary.
    public let consentText: ConsentText?


    public init(
        contents: [PayloadContent]?,
        description: String?,
        displayName: DisplayName?,
        expired: Date?,
        identifier: PayloadIdentifier,
        organization: OrganizationName?,
        uuid: UUID,
        isRemovalDisallowed: Bool?,
        scope: PayloadScope?,
        autoRemoving: AutoRemovingConfiguration?,
        consentText: ConsentText?
    ) {
        self.contents = contents
        self.description = description
        self.displayName = displayName
        self.expired = expired
        self.identifier = identifier
        self.organization = organization
        self.uuid = uuid
        self.isRemovalDisallowed = isRemovalDisallowed
        self.scope = scope
        self.autoRemoving = autoRemoving
        self.consentText = consentText
    }


    public func generatePlist() -> PlistDocument {
        return PlistDocument(root: self.serializableRepresentationContent)
    }


    public var serializableRepresentationContent: [String: PlistSerializable] {
        var result = [String: PlistSerializable]()

        if let contents = self.contents {
            // NOTE: Make stable
            result[TopLevelKey.content] = .from(contents
                .sorted { (a, b) in a.type > b.type }
                .map { $0.serializableRepresentation })
        }

        if let description = self.description {
            result[TopLevelKey.description] = .from(description)
        }

        if let displayName = self.displayName {
            result[TopLevelKey.displayName] = displayName.serializableRepresentation
        }

        if let expired = self.expired {
            result[TopLevelKey.expirationDate] = .from(expired)
        }

        result[TopLevelKey.identifier] = self.identifier.serializableRepresentation

        if let organization = self.organization {
            result[TopLevelKey.organization] = organization.serializableRepresentation
        }

        result[TopLevelKey.uuid] = .from(self.uuid.uuidString)

        if let isRemovalDisallowed = self.isRemovalDisallowed {
            result[TopLevelKey.removalDisallowed] = .from(isRemovalDisallowed)
        }

        result[TopLevelKey.type] = self.type.serializableRepresentation
        result[TopLevelKey.version] = self.version.serializableRepresentation

        if let scope = self.scope {
            result[TopLevelKey.scope] = scope.serializableRepresentation
        }

        switch self.autoRemoving {
        case .none:
            break
        case .some(.willRemoveAt(let date)):
            result[TopLevelKey.removalDate] = .from(date)
        case .some(.willRemoveUntil(let duration)):
            result[TopLevelKey.durationUntilRemoval] = .from(duration)
        }

        if let consentText = self.consentText {
            result[TopLevelKey.consentText] = consentText.serializableRepresentation
        }

        return result
    }


    public enum TopLevelKey {
        public static let content = "PayloadContent"
        public static let description = "PayloadDescription"
        public static let displayName = "PayloadDisplayName"
        public static let expirationDate = "PayloadExpirationDate"
        public static let identifier = "PayloadIdentifier"
        public static let organization = "PayloadOrganization"
        public static let uuid = "PayloadUUID"
        public static let removalDisallowed = "PayloadRemovalDisallowed"
        public static let type = "PayloadType"
        public static let version = "PayloadVersion"
        public static let scope = "PayloadScope"
        public static let removalDate = "RemovalDate"
        public static let durationUntilRemoval = "DurationUntilRemoval"
        public static let consentText = "ConsentText"
    }


    public enum CommonKey {
        public static let type = "PayloadType"
        public static let version = "PayloadVersion"
        public static let identifier = "PayloadIdentifier"
        public static let uuid = "PayloadUUID"
        public static let displayName = "PayloadDisplayName"
        public static let description = "PayloadDescription"
        public static let organization = "PayloadOrganization"
    }


    public enum PayloadContent: Equatable {
        case wiFi(WiFiMobileConfig)


        public var type: PayloadType {
            switch self {
            case .wiFi(let wiFi):
                return wiFi.type
            }
        }


        public var serializableRepresentation: PlistSerializable {
            switch self {
            case .wiFi(let wiFi):
                return wiFi.serializableRepresentation
            }
        }
    }


    public struct DisplayName: Equatable {
        private let text: String


        public init(displayName text: String) {
            self.text = text
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.text)
        }


        // NOTE: This is a default value for Wi-Fi configurations of Apple Configurator 2.
        public static let wiFi = DisplayName(displayName: "Wi-Fi")
    }


    public struct PayloadIdentifier: Equatable {
        private let text: String


        public init(identifier text: String) {
            self.text = text
        }


        public static func from(uuid: UUID, type: PayloadType) -> PayloadIdentifier {
            return PayloadIdentifier(identifier: "\(type.text).\(uuid.uuidString)")
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.text)
        }
    }


    public struct PayloadType: Equatable {
        internal let text: String


        public init(type text: String) {
            self.text = text
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.text)
        }


        public static let mobileConfig = PayloadType(type: "Configuration")
        public static let wiFi = PayloadType(type: "com.apple.wifi.managed")
    }


    public struct OrganizationName: Equatable {
        private let text: String


        public init(organizationName text: String) {
            self.text = text
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.text)
        }
    }


    public struct PayloadVersion: Equatable {
        private let number: Int


        public init(version: Int) {
            self.number = version
        }


        public var serializableRepresentation: PlistSerializable {
            return .from(self.number)
        }
    }


    public enum PayloadScope: Equatable {
        case system
        case user


        public var serializableRepresentation: PlistSerializable {
            switch self {
            case .system:
                return .from("System")
            case .user:
                return .from("User")
            }
        }
    }


    public struct ConsentText: Equatable {
        private let localized: [IETFBCP47Identifier: String]


        public init(consentTextsForEachLanguages localized: [IETFBCP47Identifier: String]) {
            self.localized = localized
        }


        public var serializableRepresentation: PlistSerializable {
            let dictionary = self.localized.reduce(into: [String: PlistSerializable]()) { (result, entry) in
                let (language, text) = entry
                result[language.text] = .from(text)
            }
            return .from(dictionary)
        }


        public struct IETFBCP47Identifier: Hashable {
            internal let text: String


            public init(ietfBCP47Identifier text: String) {
                self.text = text
            }


            public static let `default` = IETFBCP47Identifier(ietfBCP47Identifier: "default")
            public static let en = IETFBCP47Identifier(ietfBCP47Identifier: "en")
            public static let jp = IETFBCP47Identifier(ietfBCP47Identifier: "jp")
        }
    }


    public enum AutoRemovingConfiguration: Equatable {
        case willRemoveAt(Date)
        case willRemoveUntil(Duration)
    }


    public typealias Duration = Float
}



extension MobileConfig.PayloadVersion: Comparable {
    public static func <(lhs: MobileConfig.PayloadVersion, rhs: MobileConfig.PayloadVersion) -> Bool {
        return lhs.number < rhs.number
    }
}



extension MobileConfig.PayloadType: Comparable {
    public static func <(lhs: MobileConfig.PayloadType, rhs: MobileConfig.PayloadType) -> Bool {
        return lhs.text < rhs.text
    }
}
