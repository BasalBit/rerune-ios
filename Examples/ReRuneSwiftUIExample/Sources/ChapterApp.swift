import SwiftUI

@main
struct ChapterApp: App {
    @StateObject private var store: ChapterStore

    init() {
        ChapterSDK.configure()
        ChapterStyle.verifyFonts()
        _store = StateObject(wrappedValue: ChapterStore(runtime: ChapterSDK.runtime()))
    }

    var body: some Scene {
        WindowGroup {
            ChapterLibraryView(store: store)
                .preferredColorScheme(.dark)
                .task { await store.setVariant(store.variantSelected, restoring: true) }
        }
    }
}
