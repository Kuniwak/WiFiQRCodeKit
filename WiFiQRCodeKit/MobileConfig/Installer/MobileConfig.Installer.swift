import UIKit



public extension MobileConfig {
    typealias DistributionServer = MobileConfigDistributionServer
    typealias DistributionServerState = MobileConfigDistributionServerState


    class Installer {
        fileprivate let distributionServer: DistributionServer
        fileprivate let urlOpener: URLOpener
        fileprivate let distributionServerStatus: DistributionServerState


        public init(
            distributingBy distributionServer: DistributionServer,
            openingURLBy urlOpener: URLOpener = ApplicationURLOpener(on: UIApplication.shared)
        ) {
            self.distributionServer = distributionServer
            self.distributionServerStatus = distributionServer.start()
            self.urlOpener = urlOpener
        }


        public func install(mobileConfig: MobileConfig) -> InstallationResult {
            switch self.distributionServerStatus {
            case .failed(because: let reason):
                return .failed(because: .distributionServerProblem(reason))

            case .successfullyStarted:
                switch mobileConfig.generatePlist().serializeAsPlistXML() {
                case .success(let data):
                    self.distributionServer.update(
                        mobileConfigData: data,
                        mimeType: MIMEType.mobileConfig.text
                    )
                    self.urlOpener.open(url: self.distributionServer.distributionURL)
                    return .confirming

                case .failed(because: let reason):
                    return .failed(because: .serializationProblem(reason))
                }
            }
        }


        public func keepDistributionServerForBackground(for application: UIApplication) {
            var taskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

            taskIdentifier = application.beginBackgroundTask(withName: "Awaiting install a provisioning profile") {
                DispatchQueue.main.async {
                    application.endBackgroundTask(convertToUIBackgroundTaskIdentifier(taskIdentifier.rawValue))
                    taskIdentifier = UIBackgroundTaskIdentifier.invalid
                }
            }
        }


        public enum InstallationResult: Equatable {
            case confirming
            case failed(because: InstallationFailure)
        }


        public enum InstallationFailure: Equatable {
            case distributionServerProblem(MobileConfigDistributionServerState.FailureReason)
            case serializationProblem(PlistDocument.SerializationFailureReason)
        }
    }
}



public protocol MobileConfigDistributionServer {
    var distributionURL: URL { get }
    func start() -> MobileConfigDistributionServerState
    func update(mobileConfigData: Data, mimeType: String)
}



public enum MobileConfigDistributionServerState: Equatable {
    case successfullyStarted
    case failed(because: FailureReason)

    public typealias FailureReason = String
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
