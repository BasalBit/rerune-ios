import Combine
import Foundation
import ReRune

enum ChapterSDK {
    static let localePreference = "rerune.example.selectedLocale"
    static let variantPreference = "rerune.example.isVariantSelected"
    static let resources: Bundle = {
        guard let url = Bundle.main.url(forResource: "Chapter", withExtension: "bundle"),
              let bundle = Bundle(url: url) else { preconditionFailure("Chapter.bundle is missing from the app target") }
        return bundle
    }()

    // Verbose SDK logging in Debug builds only. Release builds keep the SDK
    // default level, .off.
    #if DEBUG
    private static let logLevel: ReRuneLogLevel = .verbose
    #else
    private static let logLevel: ReRuneLogLevel = .off
    #endif

    static func configure() {
        let publishID = Bundle.main.object(forInfoDictionaryKey: "RERUNE_OTA_PUBLISH_ID") as? String
            ?? ProcessInfo.processInfo.environment["RERUNE_OTA_PUBLISH_ID"]
            ?? "replace-with-ota-publish-id"
        // The saved language is selected before setup, so setup starts in it
        // and only its lookup chain loads at launch. No saved language uses
        // the device language.
        reRuneSetLocale(UserDefaults.standard.string(forKey: localePreference))
        reRuneSetup(
            otaPublishId: publishID,
            logLevel: logLevel,
            staging: false
        )
    }

    @MainActor
    static func runtime() -> ChapterRuntime {
        let slug = (Bundle.main.object(forInfoDictionaryKey: "RERUNE_VARIANT_SLUG") as? String ?? "vip")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let variant = slug.isEmpty ? "vip" : slug
        return ChapterRuntime(
            strings: {
                let fallback = ChapterStrings.bundled(locale: selectedLocale(), in: resources)
                return ChapterStrings { key in
                    Bundle.main.localizedString(forKey: key, value: fallback.resolve(key), table: "Localizable")
                }
            },
            selectedLocale: selectedLocale,
            locales: {
                var names = Dictionary(uniqueKeysWithValues: resources.localizations.filter { $0 != "Base" }.map {
                    ($0, Locale(identifier: $0).localizedString(forIdentifier: $0) ?? $0)
                })
                for locale in reRuneAvailableLocaleDetails { names[locale.identifier] = locale.name ?? names[locale.identifier] ?? locale.identifier }
                names[selectedLocale()] = names[selectedLocale()] ?? selectedLocale()
                return names.sorted { $0.key < $1.key }.map { ReadingLocale(code: $0.key, name: $0.value) }
            },
            selectLocale: {
                UserDefaults.standard.set($0, forKey: localePreference)
                reRuneSetLocale($0)
            },
            refresh: {
                switch await reRuneCheckForUpdates().status {
                case .updated: return .updated
                case .noChange: return .unchanged
                case .failed: return .failed
                @unknown default: return .unchanged
                }
            },
            selectVariant: { selected in
                try await reRuneSetVariant(selected ? ReRuneVariant(variant) : .main, persist: true)
            },
            savedVariant: { UserDefaults.standard.bool(forKey: variantPreference) },
            persistVariant: { UserDefaults.standard.set($0, forKey: variantPreference) },
            setStagingMode: { enabled in
                let result = try await reRuneSetStagingMode(enabled)
                switch result.status {
                case .updated: return .updated
                case .noChange: return .unchanged
                case .failed: return .failed
                @unknown default: return .unchanged
                }
            },
            stagingModeActive: { reRuneIsStagingModeEnabled },
            revisions: Publishers.Merge(
                reRuneRevisionPublisher.map { _ in () },
                reRuneAvailableLocaleDetailsPublisher.map { _ in () }
            ).receive(on: DispatchQueue.main).eraseToAnyPublisher(),
            variantName: variant
        )
    }

    private static func selectedLocale() -> String {
        reRuneSelectedLocale ?? Locale.preferredLanguages.first ?? "en"
    }
}
