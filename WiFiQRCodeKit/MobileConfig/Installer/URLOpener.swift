import UIKit



public protocol URLOpener {
    func open(url: URL)
}



public class ApplicationURLOpener: URLOpener {
    private weak var application: UIApplication?


    public init(on application: UIApplication) {
        self.application = application
    }


    public func open(url: URL) {
        guard let application = self.application else { return }

        if #available(iOS 10.0, *) {
            application.open(url)
        }
        else {
            application.openURL(url)
        }
    }
}
