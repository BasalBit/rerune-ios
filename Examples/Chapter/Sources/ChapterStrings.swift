import Foundation

struct ChapterStrings {
    let resolve: (String) -> String

    func callAsFunction(_ key: ChapterKey) -> String {
        resolve(key.rawValue)
    }

    static func bundled(locale: String, in resources: Bundle) -> ChapterStrings {
        let normalized = locale.replacingOccurrences(of: "_", with: "-")
        let components = normalized.split(separator: "-")
        let chain = stride(from: components.count, through: 1, by: -1).map {
            components.prefix($0).joined(separator: "-")
        } + ["en"]
        let bundles = chain.compactMap { resources.path(forResource: $0, ofType: "lproj") }
            .compactMap(Bundle.init(path:))
        return ChapterStrings { key in
            for bundle in bundles {
                let value = bundle.localizedString(forKey: key, value: key, table: "Localizable")
                if value != key { return value }
            }
            return key
        }
    }
}

enum ChapterKey: String {
    case atlas_body_four
    case atlas_body_three
    case atlas_chapter_one
    case atlas_chapter_two
    case atlas_description
    case back_library
    case collection_issue
    case currently_reading
    case discover_subtitle
    case discover_title
    case edition_change_error
    case explore_stories
    case filter_all
    case finish_story
    case garden_body_four
    case garden_body_one
    case garden_body_three
    case garden_body_two
    case garden_chapter_one
    case garden_chapter_two
    case garden_description
    case garden_title
    case genre_adventure
    case genre_nature
    case genre_wonder
    case lantern_body_four
    case lantern_body_one
    case lantern_body_three
    case lantern_body_two
    case lantern_chapter_one
    case lantern_chapter_two
    case lantern_description
    case lantern_title
    case library_footer
    case nav_discover
    case nav_library
    case nav_saved
    case next_chapter
    case next_chapter_shelf
    case read_again
    case reader_end_body
    case reader_end_title
    case reading_moment
    case reading_quote
    case reading_settings
    case refresh_current
    case refresh_error
    case remove_saved
    case save_story
    case saved_empty_body
    case saved_empty_title
    case saved_subtitle
    case saved_title
    case see_all
    case session_note
    case settings_description
    case story_body_primary
    case story_body_secondary
    case story_caption
    case story_finished
    case story_refresh_cta
    case story_title
    case translation_variant
    case variant_save_error
    case welcome_badge
    case welcome_last_synced_label
    case welcome_locale_label
    case welcome_locale_system_default
    case welcome_locale_value
    case welcome_open_story_cta
    case welcome_refresh_state_applying
    case welcome_refresh_state_checking
    case welcome_refresh_state_downloading
    case welcome_refresh_state_idle
    case welcome_refresh_state_success
    case welcome_subtitle
    case welcome_title
}

extension ChapterStrings {
    func chapter_progress(current: Int, total: Int) -> String {
        String.localizedStringWithFormat(resolve("chapter_progress"), current, total)
    }
    func plural_sample(count: Int) -> String {
        String.localizedStringWithFormat(resolve("plural_sample"), count)
    }
    func publish_date(publish_date: String) -> String {
        String.localizedStringWithFormat(resolve("publish_date"), publish_date)
    }
    func story_by(author: String) -> String {
        String.localizedStringWithFormat(resolve("story_by"), author)
    }
}
