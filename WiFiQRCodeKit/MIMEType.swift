public struct MIMEType: Hashable {
    public let text: String


    public init(mimeType text: String) {
        self.text = text
    }


    public static let mobileConfig = MIMEType(mimeType: "application/x-apple-aspen-config")
}