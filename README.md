WiFiQRCodeKit
=============
![Swift Compatible](https://img.shields.io/badge/Swift%20version-5-brightgreen.svg)
[![CocoaPods Status](https://img.shields.io/cocoapods/v/WiFiQRCodeKit.svg)](https://cocoapods.org/pods/WiFiQRCodeKit)
![Carhthage Compatible](https://img.shields.io/badge/Carthage-compatible-green.svg)
[![Build Status](https://www.bitrise.io/app/10d15cda3905395a/status.svg?token=RoO7CaqzdZ8oYZnJ3rBV-g&branch=master)](https://www.bitrise.io/app/10d15cda3905395a)

[In iOS 11, we can easily configure Wi-Fi networks by reading QR code for Wi-Fi](https://developer.apple.com/videos/play/fall2017/206/).
But some reasonable situations that is keeping iOS version lower than iOS 11 can exist.

WiFiQRCodeKit provides the Wi-Fi configuration feature via QR code for the situations.
It can work with iOS 8.0+.



Install
-------
### Carthage

```
github "Kuniwak/WiFiQRCodeKit" >= 1.0
```



### CocoaPods

```ruby
pod 'WiFiQRCodeKit', '~> 1.0'
```



Requirements
------------

- iOS 8.0+

And WiFiQRCodeKit requires 2 other libraries:

- A QR code reader library
- A local HTTP server library

It means that you can use any libraries you want.



Usage
-----
### Simple Example

This is an simple example for using with [yannickl/QRCodeReader.swift](https://github.com/yannickl/QRCodeReader.swift) and [httpswift/swifter](https://github.com/httpswift/swifter):


```swift
// AppDelegate.swift
import QRCodeReader
import WiFiQRCodeKit


class AppDelegate: UIResponder, UIApplicationDelegate {

    // ...

    private let installer = WiFIQRCodeKit.MobileConfig.Installer(
        distributingBy: SwifterMobileConfigDistributionServer(listeningOn: 8989)
    )

    private var qrCodeReaderWindow: UIWindow?
    private var originalWindow: UIWindow?

    // ...

    func applicationDidEnterBackground(_ application: UIApplication) {
        // This method MUST be called in the method.
        self.installer.keepDistributionServerForBackground(for: application)
    }


    // Open a QR code reader.
    func readQRCode() {
        let qrCodeReaderBuilder = QRCodeReaderViewControllerBuilder()
        qrCodeReaderBuilder.reader = QRCodeReader(
            metadataObjectTypes: [.qr],
            captureDevicePosition: .back
        )

        let qrCodeReaderViewController = QRCodeReaderViewController(builder: qrCodeReaderBuilder)
        qrCodeReaderViewController.completionBlock = { [weak self] result in
            guard let `self` = self else { return }

            if let result = result {
                self.install(qrCodeContent: result.value)
            }

            self.qrCodeReaderWindow = nil
            self.originalWindow.makeKeyAndVisible()
        }

        self.originalWindow = UIApplication.shared.keyWindow

        let qrCodeReaderWindow = UIWindow()
        qrCodeReaderWindow.rootViewController = qrCodeReaderViewController
        qrCodeReaderWindow.makeKeyAndVisible()

        self.qrCodeReaderWindow = window
    }


    // Install the Wi-Fi settings.
    private func install(qrCodeContent: String) {
        switch WiFiQRCodeKit.parse(text: qrCodeContent) {
        case .success(let wiFiQRCode):
            var mobileConfig = WiFiQRCodeKit.MobileConfig.from(
                wiFiQRCode: wiFiQRCode,
                organization: .init(organizationName: "Example, Inc.")

                // Also you can specify the following optional items:
                //
                //   identifier: .init(identifier: "com.example.WiFiSettings"),
                //   description: "Joining the Wi-Fi network that managed by Example, Inc.",
                //   displayName: .init(displayName: "Wi-Fi settings for Example, Inc."),
                //   consentText: .init(consentTextsForEachLanguages: [
                //       .default: "Would you join the Wi-Fi network that manged by Example, Inc.?",
                //       .en: "Would you join the Wi-Fi network that manged by Example, Inc.?",
                //       .jp: "Example, Inc. の Wi-Fi ネットワークへ接続しますか？",
                //   ])
            )

            // You can modify other items such as the expiration option of the configuration profile.
            // Configurable items are listed on "Configuration Profile Reference".
            // See https://developer.apple.com/library/content/featuredarticles/iPhoneConfigurationProfileRef/

            // It open the configuration profile on Safari.
            self.installer.install(mobileConfig: mobileConfig)

        case .failed(because: let reason):
            dump(reason)
        }
    }
}
```


```swift
// SwifterMobileConfigDistributionServer.swift
import Swifter
import WiFiQRCodeKit


class SwifterMobileConfigDistributionServer: WiFiQRCodeKit.MobileConfig.DistributionServer {
    let distributionURL: URL
    private let server: Swifter.HttpServer
    private let port: UInt16
    private var mobileConfig: (data: Data, mimeType: String)?


    init(listeningOn port: UInt16) {
        let mobileConfigPath = "/WiFi.mobileConfig"

        self.distributionURL = URL(string: "http://127.0.0.1:\(port)\(mobileConfigPath)")!
        self.port = port
        self.server = Swifter.HttpServer()

        self.server[mobileConfigPath] = { [weak self] (_: Swifter.HttpRequest) -> Swifter.HttpResponse in
            guard let `self` = self, let mobileConfig = self.mobileConfig else {
                return .notFound
            }

            let statusCode = 20
            let statusText = "OK"
            let headers = ["Content-Type": mobileConfig.mimeType]

            return .raw(
                statusCode,
                statusText,
                headers,
                { (writer: Swifter.HttpResponseBodyWriter) throws in
                    try writer.write(mobileConfig.data)
                }
            )
        }
    }


    func start() -> WiFiQRCodeKit.MobileConfig.DistributionServerState {
        do {
            try self.server.start(self.port)
            return .successfullyStarted
        }
        catch {
            return .failed(because: "\(error)")
        }
    }


    func update(mobileConfigData: Data, mimeType: String) {
        self.mobileConfig = (data: mobileConfigData, mimeType: mimeType)
    }
}
```



### Full Example

See [Kuniwak/WiFiQRCodeKitExampleApp](https://github.com/Kuniwak/WiFiQRCodeKitExampleApp).



Implementation Defail
---------------------

The procedure of WiFiQRCodeKit is the following:

1. Get a Wi-Fi QR code content by a QR code reader library
2. WiFiQRCodeKit create the provisioing profile for Wi-Fi settings
3. WiFiQRCodeKit start a local HTTP server that will deliver the provisoning profile
4. WiFiQRCodeKit open Safari with an URL of the local HTTP server
5. Safari confirm the provisioning profile to the user
6. Connect to the Wi-Fi



References
----------

- [Barcode Contents - zxing/zxing](https://github.com/zxing/zxing/wiki/Barcode-Contents#wifi-network-config-android)
- [Phonebook Registration - NTT docomo](https://web.archive.org/web/20111202054137/http://www.nttdocomo.co.jp/english/service/imode/make/content/barcode/function/application/addressbook/index.html)
- [Configuration Profile Reference - Apple](https://developer.apple.com/library/content/featuredarticles/iPhoneConfigurationProfileRef/)
- [Installing a configuration profile on iPhone - programmatically](https://stackoverflow.com/questions/2338035/installing-a-configuration-profile-on-iphone-programmatically/)
- [Monadic Parse Combinators](http://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf)



License
-------

The MIT License (MIT)
