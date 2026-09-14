import Combine
import Foundation

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
struct ChapterRuntime {
    var strings: () -> ChapterStrings
    var selectedLocale: () -> String
    var locales: () -> [ReadingLocale]
    var selectLocale: (String) -> Void
    var refresh: () async -> RefreshState
    var selectVariant: (Bool) async throws -> Void
    var savedVariant: () -> Bool
    var persistVariant: (Bool) -> Void
    var revisions: AnyPublisher<Void, Never>
    var variantName: String
}

@MainActor
final class ChapterStore: ObservableObject {
    @Published private(set) var reading = ReadingState()
    @Published private(set) var refreshState: RefreshState = .idle
    @Published private(set) var variantSelected: Bool
    @Published private(set) var changingVariant = false
    @Published private(set) var variantFailed = false
    @Published private(set) var textRevision = 0
    private let runtime: ChapterRuntime
    private var subscription: AnyCancellable?

    init(runtime: ChapterRuntime) {
        self.runtime = runtime
        variantSelected = runtime.savedVariant()
        subscription = runtime.revisions.sink { [weak self] in
            self?.textRevision += 1
        }
    }

    var text: ChapterStrings { runtime.strings() }
    var locale: String { runtime.selectedLocale() }
    var locales: [ReadingLocale] { runtime.locales() }
    var variantName: String { runtime.variantName }
    func selectLocale(_ code: String) {
        runtime.selectLocale(code)
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
        refreshState = await runtime.refresh()
    }

    func setVariant(_ selected: Bool, restoring: Bool = false) async {
        guard !changingVariant, refreshState != .busy,
              restoring || selected != variantSelected else { return }
        changingVariant = true
        variantFailed = false
        defer { changingVariant = false }
        do {
            try await runtime.selectVariant(selected)
            variantSelected = selected
            runtime.persistVariant(selected)
        } catch {
            // The SDK persists first. A failure leaves the active edition unchanged.
            variantFailed = true
        }
    }
}
