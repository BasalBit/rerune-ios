import Combine
import UIKit
import ReRune

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        _ = launchOptions
        let publishId = Bundle.main.object(forInfoDictionaryKey: "RERUNE_OTA_PUBLISH_ID") as? String
            ?? ProcessInfo.processInfo.environment["RERUNE_OTA_PUBLISH_ID"]
            ?? "replace-with-ota-publish-id"

        reRuneSetup(
            otaPublishId: publishId,
            updatePolicy: ReRuneUpdatePolicy(periodicIntervalInDays: 1),
            logLevel: .info
        )

        let controller = ViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: controller)
        window?.makeKeyAndVisible()

        reRuneRevisionPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in controller.rebindStrings() }
            .store(in: &cancellables)

        return true
    }
}
