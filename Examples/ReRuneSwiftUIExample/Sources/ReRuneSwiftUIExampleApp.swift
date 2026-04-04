import SwiftUI
import ReRune
import UIKit

@main
struct ReRuneSwiftUIExampleApp: App {
    init() {
        let publishId = Bundle.main.object(forInfoDictionaryKey: "RERUNE_OTA_PUBLISH_ID") as? String
            ?? ProcessInfo.processInfo.environment["RERUNE_OTA_PUBLISH_ID"]
            ?? "replace-with-ota-publish-id"
        reRuneSetup(otaPublishId: publishId)

        UINavigationBar.appearance().tintColor = UIColor(
            red: 245.0 / 255.0,
            green: 166.0 / 255.0,
            blue: 35.0 / 255.0,
            alpha: 1.0
        )
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -1000, vertical: 0),
            for: .default
        )
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .preferredColorScheme(.dark)
                .reRuneObserveRevision()
        }
    }
}
