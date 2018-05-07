import XCTest
@testable import WiFiQRCodeKit


class FormatterTests: XCTestCase {
    func testFormat() {
        typealias TestCase = (
            wiFiQRCode: WiFiQRCode,
            expected: String
        )

        let testCases: [UInt: TestCase] = [
            #line: (
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("ssid_only"),
                    encryptionType: .none,
                    isHidden: false
                ),
                expected: "WIFI:S:ssid_only;;"
            ),
            #line: (
                // Emoji (this is the flag of Japan)
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("\u{1F1EF}\u{1F1F5}"),
                    encryptionType: .none,
                    isHidden: false
                ),
                expected: "WIFI:S:\u{1F1EF}\u{1F1F5};;"
            ),
            #line: (
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("hidden_ssid"),
                    encryptionType: .none,
                    isHidden: true
                ),
                expected: "WIFI:S:hidden_ssid;H:true;;"
            ),
            #line: (
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("nopass"),
                    encryptionType: .none,
                    isHidden: false
                ),
                expected: "WIFI:S:nopass;;"
            ),
            #line: (
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("wep"),
                    encryptionType: .wep(Password("password")),
                    isHidden: false
                ),
                expected: "WIFI:S:wep;T:WEP;P:password;;"
            ),
            #line: (
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("wpa"),
                    encryptionType: .wpa(Password("password")),
                    isHidden: false
                ),
                expected: "WIFI:S:wpa;T:WPA;P:password;;"
            ),

            // From: https://github.com/zxing/zxing/wiki/Barcode-Contents#wifi-network-config-android
            #line: (
                wiFiQRCode: WiFiQRCode(
                    ssid: SSID("\"foo;bar\\baz\""),
                    encryptionType: .none,
                    isHidden: false
                ),
                expected: "WIFI:S:\\\"foo\\;bar\\\\baz\\\";;"
            )
        ]

        testCases.forEach { (line, testCase) in
            let (wiFiQrCode, expected) = testCase

            let actual = WiFiQRCodeKit.format(wiFiQRCode: wiFiQrCode)

            XCTAssertEqual(actual, expected, line: line)
        }
    }
}
