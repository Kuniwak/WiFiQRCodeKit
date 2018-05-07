import XCTest
import WiFiQRCodeKit



class WiFiQRCodeKitTests: XCTestCase {
    func testParsingExample() {
        let string = "WIFI:T:WPA;S:my_network;P:my_pass;;"
        let result = WiFiQRCodeKit.parse(text: string)

        switch result {
        case .success(let wiFiQRCode):
            XCTAssertEqual(wiFiQRCode.ssid, SSID("my_network"))
            XCTAssertFalse(wiFiQRCode.isHidden)
            XCTAssertEqual(wiFiQRCode.encryptionType, .wpa(Password("my_pass")))
        case .failed:
            XCTFail()
        }
    }


    func testFormattingExample() {
        let wiFiQRCode = WiFiQRCode(
            ssid: SSID("my_network"),
            encryptionType: .wpa(Password("my_pass")),
            isHidden: false
        )

        let content = WiFiQRCodeKit.format(wiFiQRCode: wiFiQRCode)

        XCTAssertEqual(content, "WIFI:S:my_network;T:WPA;P:my_pass;;")
    }
}
