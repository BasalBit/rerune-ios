import SwiftUI
import ReRune

@main
struct ReRuneSwiftUIExampleApp: App {
    init() {
        let publishId = Bundle.main.object(forInfoDictionaryKey: "RERUNE_OTA_PUBLISH_ID") as? String
            ?? ProcessInfo.processInfo.environment["RERUNE_OTA_PUBLISH_ID"]
            ?? "replace-with-ota-publish-id"
        reRuneSetup(
            otaPublishId: publishId,
            updatePolicy: ReRuneUpdatePolicy(periodicIntervalInDays: 1),
            logLevel: .info
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .reRuneObserveRevision()
        }
    }
}
