import SwiftUI

struct ChapterReaderView: View {
    @ObservedObject var store: ChapterStore
    let id: StoryID
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var chapterFocused: Bool
    @ScaledMetric(relativeTo: .body) private var proseSpacing: CGFloat = 12
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left").font(.system(size: 22)).frame(width: 48, height: 48)
                }.accessibilityLabel(store.text(.back_library))
                Text(store.text(id.story.title)).font(ReadingFont.sans(16, bold: true))
                    .frame(maxWidth: .infinity).multilineTextAlignment(.center)
                LanguageMenu(store: store)
            }.padding(.horizontal, 16).foregroundColor(Color(ChapterStyle.secondary))
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        StoryCover(id: id).frame(height: 200).id("reader.top")
                            .overlay(alignment: .bottomTrailing) { BookmarkButton(store: store, id: id, onCover: true).padding(14) }
                        ReadingProgress(store: store, id: id)
                        if store.reading.isFinished(id) {
                            VStack(spacing: 24) {
                                Image(systemName: "book.fill").font(.system(size: 38)).foregroundColor(Color(ChapterStyle.accent))
                                Text(store.text(.reader_end_title)).font(ReadingFont.sans(28, bold: true, relativeTo: .title))
                                    .accessibilityAddTraits(.isHeader).accessibilityFocused($chapterFocused)
                                Text(store.text(.reader_end_body)).font(ReadingFont.sans(15)).foregroundColor(Color(ChapterStyle.secondary))
                                ReadingAction(title: store.text(.read_again)) { store.restart(id) }
                                    .accessibilityIdentifier("read.again")
                            }.multilineTextAlignment(.center).frame(maxWidth: .infinity)
                        } else {
                            let chapter = id.story.chapters[store.reading.chapterIndex(id)]
                            VStack(alignment: .leading, spacing: 12) {
                                Text(store.text(chapter.title)).font(ReadingFont.serif(30, relativeTo: .title)).lineSpacing(5)
                                    .accessibilityAddTraits(.isHeader).accessibilityFocused($chapterFocused)
                                Text(store.text.story_by(author: id.story.author)).font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
                            }
                            ForEach(chapter.paragraphs, id: \.rawValue) { key in
                                Text(store.text(key)).font(ReadingFont.serif(19)).lineSpacing(proseSpacing)
                                    .foregroundColor(Color(ChapterStyle.prose)).fixedSize(horizontal: false, vertical: true)
                            }
                            ReadingAction(title: store.text(store.reading.chapterIndex(id) == 0 ? .next_chapter : .finish_story), symbol: "arrow.right") {
                                store.finishChapter(id)
                            }.accessibilityIdentifier("chapter.advance")
                        }
                        RefreshTexts(store: store)
                    }.frame(maxWidth: ChapterStyle.readerWidth).padding(24).frame(maxWidth: .infinity)
                }
                .onChange(of: store.reading.completed(id)) { _ in
                    proxy.scrollTo("reader.top", anchor: .top)
                    chapterFocused = true
                }
            }
        }
        .background(Color(ChapterStyle.background).ignoresSafeArea())
        .foregroundColor(Color(ChapterStyle.primary)).navigationBarHidden(true)
    }
}
