import Combine
import UIKit
import ReRune

protocol ReRuneTextRefreshable: AnyObject {
    func rebindStrings()
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()
    private let navigationController = UINavigationController()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        _ = launchOptions
        let publishId = Bundle.main.object(forInfoDictionaryKey: "RERUNE_OTA_PUBLISH_ID") as? String
            ?? ProcessInfo.processInfo.environment["RERUNE_OTA_PUBLISH_ID"]
            ?? "replace-with-ota-publish-id"

        reRuneSetup(otaPublishId: publishId)
        configureAppearance()

        let controller = WelcomeViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        navigationController.viewControllers = [controller]
        window?.overrideUserInterfaceStyle = .dark
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        reRuneRevisionPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController.viewControllers
                    .compactMap { $0 as? ReRuneTextRefreshable }
                    .forEach { $0.rebindStrings() }
            }
            .store(in: &cancellables)

        return true
    }

    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: DemoTheme.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: DemoTheme.textPrimary]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = DemoTheme.accentPrimary
    }
}
