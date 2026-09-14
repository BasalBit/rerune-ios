import Combine
import Foundation
import ReRune

enum RefreshState: Equatable {
    case idle, busy, updated, unchanged, failed
    var label: ChapterKey? {
        switch self {
        case .idle: return nil
        case .busy: return .welcome_refresh_state_checking
        case .updated: return .welcome_refresh_state_success
        case .unchanged: return .refresh_current
        case .failed: return .refresh_error
        }
    }
}

struct ReadingLocale {
    let code: String
    let name: String
}

@MainActor
final class ChapterStore: ObservableObject {
    private static let localePreference = "rerune.example.selectedLocale"
    private static let variantPreference = "rerune.example.isVariantSelected"
    private static let resources: Bundle = {
        guard let url = Bundle.main.url(forResource: "ReRuneResources", withExtension: "bundle"),
              let bundle = Bundle(url: url) else { preconditionFailure("ReRuneResources.bundle is missing from the app target") }
        return bundle
    }()

    @Published private(set) var reading = ReadingState()
    @Published private(set) var refreshState: RefreshState = .idle
    @Published private(set) var variantSelected: Bool
    @Published private(set) var changingVariant = false
    @Published private(set) var variantFailed = false
    @Published private(set) var textRevision = 0
    let variantName: String
    private var subscription: AnyCancellable?

    init() {
        guard let publishID = Bundle.main.object(forInfoDictionaryKey: "RERUNE_OTA_PUBLISH_ID") as? String,
              !publishID.isEmpty else { preconditionFailure("Set RERUNE_OTA_PUBLISH_ID in Config/Example.xcconfig") }
        let slug = (Bundle.main.object(forInfoDictionaryKey: "RERUNE_VARIANT_SLUG") as? String ?? "vip")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        variantName = slug.isEmpty ? "vip" : slug
        variantSelected = UserDefaults.standard.bool(forKey: Self.variantPreference)

        reRuneSetup(otaPublishId: publishID, logLevel: .info)
        reRuneSetLocale(UserDefaults.standard.string(forKey: Self.localePreference))
        subscription = Publishers.Merge(
            reRuneRevisionPublisher.map { _ in () },
            reRuneAvailableLocaleDetailsPublisher.map { _ in () }
        ).receive(on: DispatchQueue.main).sink { [weak self] in
            self?.textRevision += 1
        }
    }

    var text: ChapterStrings {
        let fallback = ChapterStrings.bundled(locale: locale, in: Self.resources)
        return ChapterStrings { key in
            Bundle.main.localizedString(forKey: key, value: fallback.resolve(key), table: "Localizable")
        }
    }
    var locale: String { reRuneSelectedLocale ?? Locale.preferredLanguages.first ?? "en" }
    var locales: [ReadingLocale] {
        var names = Dictionary(uniqueKeysWithValues: Self.resources.localizations.filter { $0 != "Base" }.map {
            ($0, Locale(identifier: $0).localizedString(forIdentifier: $0) ?? $0)
        })
        for detail in reRuneAvailableLocaleDetails {
            names[detail.identifier] = detail.name ?? names[detail.identifier] ?? detail.identifier
        }
        names[locale] = names[locale] ?? locale
        return names.sorted { $0.key < $1.key }.map { ReadingLocale(code: $0.key, name: $0.value) }
    }
    func selectLocale(_ code: String) {
        UserDefaults.standard.set(code, forKey: Self.localePreference)
        reRuneSetLocale(code)
        textRevision += 1
    }
    func selectTab(_ tab: LibraryTab) { reading.tab = tab }
    func selectGenre(_ genre: Genre) { reading.genre = genre }
    func open(_ id: StoryID) { reading.open(id) }
    func toggleSaved(_ id: StoryID) { reading.toggleSaved(id) }
    func finishChapter(_ id: StoryID) { reading.finishChapter(id) }
    func restart(_ id: StoryID) { reading.restart(id) }

    func progressLabel(_ id: StoryID) -> String {
        reading.isFinished(id) ? text(.story_finished) : text.chapter_progress(
            current: reading.chapterIndex(id) + 1, total: id.story.chapters.count
        )
    }

    func refresh() async {
        guard refreshState != .busy, !changingVariant else { return }
        refreshState = .busy
        switch await reRuneCheckForUpdates().status {
        case .updated: refreshState = .updated
        case .noChange: refreshState = .unchanged
        case .failed: refreshState = .failed
        }
    }

    func setVariant(_ selected: Bool, restoring: Bool = false) async {
        guard !changingVariant, refreshState != .busy,
              restoring || selected != variantSelected else { return }
        changingVariant = true
        variantFailed = false
        defer { changingVariant = false }
        do {
            try await reRuneSetVariant(selected ? ReRuneVariant(variantName) : .main, persist: true)
            variantSelected = selected
            UserDefaults.standard.set(selected, forKey: Self.variantPreference)
        } catch {
            // The SDK persists first. A failure leaves the active edition unchanged.
            variantFailed = true
        }
    }
}
