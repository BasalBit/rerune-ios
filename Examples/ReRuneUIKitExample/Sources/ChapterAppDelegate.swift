import UIKit

@main
final class ChapterAppDelegate: UIResponder, UIApplicationDelegate {
    // The reading store belongs to the process, so reading state survives a
    // scene that the system disconnects and reconnects.
    private(set) var store: ChapterStore?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ChapterSDK.configure()
        ChapterStyle.verifyFonts()
        let store = ChapterStore(runtime: ChapterSDK.runtime())
        self.store = store
        Task { await store.setVariant(store.variantSelected, restoring: true) }
        return true
    }
}

// Declared in the Info.plist scene manifest. Owns the window of the app's
// single scene.
final class ChapterSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        guard let store = (UIApplication.shared.delegate as? ChapterAppDelegate)?.store else {
            preconditionFailure("ChapterAppDelegate creates the store at launch")
        }
        let navigation = UINavigationController(rootViewController: ChapterLibraryController(store: store))
        navigation.setNavigationBarHidden(true, animated: false)
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        window.tintColor = ChapterStyle.accent
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
    }
}
