import UIKit

@main
final class ChapterAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var store: ChapterStore?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ChapterStyle.verifyFonts()
        let store = ChapterStore()
        self.store = store
        let navigation = UINavigationController(rootViewController: ChapterLibraryController(store: store))
        navigation.setNavigationBarHidden(true, animated: false)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .dark
        window.tintColor = ChapterStyle.accent
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
        Task { await store.setVariant(store.variantSelected, restoring: true) }
        return true
    }
}
