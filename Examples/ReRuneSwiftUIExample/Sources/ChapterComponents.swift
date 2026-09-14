import SwiftUI

enum ReadingFont {
    static func sans(_ size: CGFloat, bold: Bool = false, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(bold ? "InstrumentSans-Bold" : "InstrumentSans-Regular", size: size, relativeTo: style)
    }
    static func serif(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("Lora-Regular", size: size, relativeTo: style)
    }
}

struct StoryCover: View {
    let id: StoryID
    var body: some View {
        Canvas { context, size in
            context.withCGContext { CoverArtwork.draw(id, in: $0, size: size) }
        }
        .clipShape(RoundedRectangle(cornerRadius: ChapterStyle.radius))
        .accessibilityHidden(true)
    }
}

struct ReadingAction: View {
    let title: String
    var symbol: String? = nil
    var primary = true
    var busy = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if busy { ProgressView().tint(Color(ChapterStyle.accent)) }
                Text(title).fixedSize(horizontal: false, vertical: true)
                if let symbol { Image(systemName: symbol) }
            }
            .font(ReadingFont.sans(16, bold: true))
            .frame(maxWidth: .infinity, minHeight: 24)
            .padding(.horizontal, 16).padding(.vertical, 14)
            .foregroundColor(Color(primary ? ChapterStyle.background : ChapterStyle.secondary))
            .background(Color(primary ? ChapterStyle.accent : .clear))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(primary ? .clear : ChapterStyle.border)))
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }
}

struct BookmarkButton: View {
    @ObservedObject var store: ChapterStore
    let id: StoryID
    var onCover = false
    var body: some View {
        Button { store.toggleSaved(id) } label: {
            Image(systemName: store.reading.saved.contains(id) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 48, height: 48)
                .foregroundColor(Color(ChapterStyle.primary))
                .background(onCover ? Color(ChapterStyle.background).opacity(0.88) : .clear)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(store.text(store.reading.saved.contains(id) ? .remove_saved : .save_story))
        .accessibilityValue(store.text(id.story.title))
        .accessibilityIdentifier("bookmark.\(id.rawValue)")
    }
}

struct ReadingProgress: View {
    @ObservedObject var store: ChapterStore
    let id: StoryID
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(store.progressLabel(id)).font(ReadingFont.sans(14, bold: true))
                Spacer(minLength: 12)
                Text(store.reading.progress(id), format: .percent.precision(.fractionLength(0)))
                    .font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
            }
            GeometryReader { proxy in
                Capsule().fill(Color(ChapterStyle.border))
                    .overlay(alignment: .leading) {
                        Capsule().fill(Color(ChapterStyle.accent))
                            .frame(width: proxy.size.width * store.reading.progress(id))
                    }
            }.frame(height: 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("progress.\(id.rawValue)")
    }
}

struct LanguageMenu: View {
    @ObservedObject var store: ChapterStore
    var body: some View {
        Menu {
            ForEach(store.locales, id: \.code) { locale in
                Button { store.selectLocale(locale.code) } label: {
                    if store.locale == locale.code {
                        Label(locale.name, systemImage: "checkmark")
                    } else { Text(locale.name) }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                Text(store.locale.split(separator: "-").first.map(String.init)?.uppercased() ?? store.locale)
                    .font(ReadingFont.sans(13))
                Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(Color(ChapterStyle.secondary)).frame(minWidth: 48, minHeight: 48)
        }
        .accessibilityLabel(store.text(.welcome_locale_label))
        .accessibilityValue(store.locale)
        .accessibilityIdentifier("language")
    }
}

struct RefreshTexts: View {
    @ObservedObject var store: ChapterStore
    var body: some View {
        VStack(spacing: 12) {
            ReadingAction(title: store.text(.story_refresh_cta), symbol: "arrow.clockwise", primary: false,
                          busy: store.refreshState == .busy) { Task { await store.refresh() } }
                .disabled(store.changingVariant)
                .accessibilityIdentifier("refresh")
            if let key = store.refreshState.label {
                Text(store.text(key)).font(ReadingFont.sans(13))
                    .foregroundColor(Color(store.refreshState == .failed ? .systemRed : ChapterStyle.secondary))
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("refresh.result")
            }
        }
    }
}
