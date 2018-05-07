import XCTest
@testable import WiFiQRCodeKit


class ParserTests: XCTestCase {
    func testParse() {
        typealias TestCase = (
            text: String,
            expected: ParsingResult<WiFiQRCode, ParsingFailureReason>
        )

        let testCases: [UInt: TestCase] = [
            #line: (
                text: "",
                expected: .failed(because: .syntaxError)
            ),
            #line: (
                text: "INVALID",
                expected: .failed(because: .syntaxError)
            ),
            #line: (
                text: "WIFI:;",
                expected: .failed(because: .semanticProblem(.missingSSID))
            ),
            #line: (
                text: "WIFI:S:broken_escape\\;;",
                expected: .failed(because: .syntaxError)
            ),
            #line: (
                text: "WIFI:S:ssid_only;;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("ssid_only"),
                    encryptionType: .none,
                    isHidden: false
                ))
            ),
            #line: (
                // Emoji (this is the flag of Japan)
                text: "WIFI:S:\u{1F1EF}\u{1F1F5};;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("\u{1F1EF}\u{1F1F5}"),
                    encryptionType: .none,
                    isHidden: false
                ))
            ),
            #line: (
                text: "WIFI:S:hidden_ssid;H:true;;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("hidden_ssid"),
                    encryptionType: .none,
                    isHidden: true
                ))
            ),
            #line: (
                text: "WIFI:S:explicit_nopass;T:nopass;;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("explicit_nopass"),
                    encryptionType: .none,
                    isHidden: false
                ))
            ),
            #line: (
                text: "WIFI:S:wep;T:WEP;;",
                expected: .failed(because: .semanticProblem(.missingPassword))
            ),
            #line: (
                text: "WIFI:S:wep;T:WEP;P:password;;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("wep"),
                    encryptionType: .wep(Password("password")),
                    isHidden: false
                ))
            ),
            #line: (
                text: "WIFI:S:wpa;T:WPA;;",
                expected: .failed(because: .semanticProblem(.missingPassword))
            ),
            #line: (
                text: "WIFI:S:wpa;T:WPA;P:password;;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("wpa"),
                    encryptionType: .wpa(Password("password")),
                    isHidden: false
                ))
            ),

            // From: https://github.com/zxing/zxing/wiki/Barcode-Contents#wifi-network-config-android
            #line: (
                text: "WIFI:T:WPA;S:mynetwork;P:mypass;;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("mynetwork"),
                    encryptionType: .wpa(Password("mypass")),
                    isHidden: false
                ))
            ),

            // From: https://github.com/zxing/zxing/wiki/Barcode-Contents#wifi-network-config-android
            #line: (
                text: "WIFI:S:\\\"foo\\;bar\\\\baz\\\";;",
                expected: .success(WiFiQRCode(
                    ssid: SSID("\"foo;bar\\baz\""),
                    encryptionType: .none,
                    isHidden: false
                ))
            )
        ]

        testCases.forEach { (line, testCase) in
            let (text, expected) = testCase

            let actual = WiFiQRCodeKit.parse(text: text)

            XCTAssertEqual(
                actual,
                expected,
                diff(between: expected, and: actual),
                line: line
            )
            if actual != expected {
                dump(WiFiQRCodeKit.wifiQRCodeContent(Substring(text)))
            }
        }
    }
}
