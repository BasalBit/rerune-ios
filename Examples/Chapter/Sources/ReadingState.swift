import Foundation

enum StoryID: String, CaseIterable, Identifiable {
    case atlas, lantern, garden
    var id: String { rawValue }

    var story: Story {
        switch self {
        case .atlas:
            return Story(id: self, title: .story_title, author: "Nora Vale", genre: .wonder,
                         description: .atlas_description, chapters: [
                            Chapter(title: .atlas_chapter_one, paragraphs: [.story_body_primary, .story_body_secondary]),
                            Chapter(title: .atlas_chapter_two, paragraphs: [.atlas_body_three, .atlas_body_four])])
        case .lantern:
            return Story(id: self, title: .lantern_title, author: "Elias North", genre: .adventure,
                         description: .lantern_description, chapters: [
                            Chapter(title: .lantern_chapter_one, paragraphs: [.lantern_body_one, .lantern_body_two]),
                            Chapter(title: .lantern_chapter_two, paragraphs: [.lantern_body_three, .lantern_body_four])])
        case .garden:
            return Story(id: self, title: .garden_title, author: "Mila Sol", genre: .nature,
                         description: .garden_description, chapters: [
                            Chapter(title: .garden_chapter_one, paragraphs: [.garden_body_one, .garden_body_two]),
                            Chapter(title: .garden_chapter_two, paragraphs: [.garden_body_three, .garden_body_four])])
        }
    }
}

struct Chapter {
    let title: ChapterKey
    let paragraphs: [ChapterKey]
}

struct Story {
    let id: StoryID
    let title: ChapterKey
    let author: String
    let genre: Genre
    let description: ChapterKey
    let chapters: [Chapter]
}

enum LibraryTab: String, CaseIterable, Identifiable {
    case library, discover, saved
    var id: String { rawValue }
    var label: ChapterKey {
        switch self { case .library: return .nav_library; case .discover: return .nav_discover; case .saved: return .nav_saved }
    }
    var symbol: String {
        switch self { case .library: return "books.vertical"; case .discover: return "safari"; case .saved: return "bookmark" }
    }
}

enum Genre: String, CaseIterable, Identifiable {
    case all, wonder, adventure, nature
    var id: String { rawValue }
    var label: ChapterKey {
        switch self {
        case .all: return .filter_all
        case .wonder: return .genre_wonder
        case .adventure: return .genre_adventure
        case .nature: return .genre_nature
        }
    }
}

struct ReadingState: Equatable {
    private(set) var current: StoryID = .atlas
    private(set) var saved: Set<StoryID> = []
    private(set) var completedChapters: [StoryID: Int] = [:]
    var tab: LibraryTab = .library
    var genre: Genre = .all

    func completed(_ id: StoryID) -> Int { completedChapters[id, default: 0] }
    func isFinished(_ id: StoryID) -> Bool { completed(id) == id.story.chapters.count }
    func chapterIndex(_ id: StoryID) -> Int { min(completed(id), id.story.chapters.count - 1) }
    func progress(_ id: StoryID) -> Double { Double(completed(id)) / Double(id.story.chapters.count) }
    func stories(in tab: LibraryTab) -> [StoryID] {
        StoryID.allCases.filter {
            switch tab {
            case .library: return $0 != current
            case .discover: return genre == .all || $0.story.genre == genre
            case .saved: return saved.contains($0)
            }
        }
    }
    mutating func open(_ id: StoryID) { current = id }
    mutating func toggleSaved(_ id: StoryID) {
        if !saved.insert(id).inserted { saved.remove(id) }
    }
    mutating func finishChapter(_ id: StoryID) {
        completedChapters[id] = min(completed(id) + 1, id.story.chapters.count)
    }
    mutating func restart(_ id: StoryID) { completedChapters.removeValue(forKey: id) }
}
