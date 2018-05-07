import Foundation
import XCTest
import WiFiQRCodeKit



class PlistDocumentTests: XCTestCase {
    func testSerializeAsPlistXML() {
        typealias TestCase = (
            plist: PlistDocument,
            expected: String
        )


        let testCases: [UInt: TestCase] = [
            #line: (
                plist: PlistDocument(root: ["Test": .from(true)]),
                expected: """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                	<key>Test</key>
                	<true/>
                </dict>
                </plist>
                
                """
            ),
            #line: (
                plist: PlistDocument(root: ["Test": .from(123 as Int)]),
                expected: """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                	<key>Test</key>
                	<integer>123</integer>
                </dict>
                </plist>
                
                """
            ),
            #line: (
                plist: PlistDocument(root: ["Test": .from(123 as Float)]),
                expected: """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                	<key>Test</key>
                	<real>123</real>
                </dict>
                </plist>
                
                """
            ),
            #line: (
                plist: PlistDocument(root: ["Test": .from("STRING")]),
                expected: """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                	<key>Test</key>
                	<string>STRING</string>
                </dict>
                </plist>
                
                """
            ),
            #line: (
                plist: PlistDocument(root: ["Test": .from([.from("ARRAY")])]),
                expected: """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                	<key>Test</key>
                	<array>
                		<string>ARRAY</string>
                	</array>
                </dict>
                </plist>
                
                """
            ),
            #line: (
                plist: PlistDocument(root: ["Test": .from(["KEY": .from("VALUE")])]),
                expected: """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                	<key>Test</key>
                	<dict>
                		<key>KEY</key>
                		<string>VALUE</string>
                	</dict>
                </dict>
                </plist>
                
                """
            ),
        ]


        testCases.forEach { tuple in
            let (line, (plist: plist, expected: expected)) = tuple

            switch plist.serializeAsPlistXML() {
            case .failed(because: let reason):
                XCTFail("\(reason)")

            case .success(let data):
                XCTAssertEqual(
                    String(data: data, encoding: .utf8)!,
                    expected,
                    line: line
                )

                if data != Data(expected.utf8) {
                    print("Actual: \(data.base64EncodedString())")
                    print("Expected: \(Data(expected.utf8).base64EncodedString())")
                }
            }
        }
    }
}
