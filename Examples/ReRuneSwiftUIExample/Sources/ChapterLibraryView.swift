import SwiftUI

struct ChapterLibraryView: View {
    @ObservedObject var store: ChapterStore
    @State private var showingSettings = false
    @State private var showingReader = false
    @State private var readerStory: StoryID = .atlas

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    ForEach(LibraryTab.allCases) { tab in
                        LibraryPage(store: store, tab: tab, settings: { showingSettings = true }, open: open)
                            .opacity(store.reading.tab == tab ? 1 : 0)
                            .allowsHitTesting(store.reading.tab == tab)
                            .accessibilityHidden(store.reading.tab != tab)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(LibraryTab.allCases) { tab in
                        Button { store.selectTab(tab) } label: {
                            VStack(spacing: 5) {
                                Image(systemName: tab.symbol + (store.reading.tab == tab ? ".fill" : ""))
                                    .font(.system(size: 22))
                                    .frame(width: 64, height: 32)
                                    .background(store.reading.tab == tab ? Color(ChapterStyle.accent).opacity(0.12) : .clear)
                                    .clipShape(Capsule())
                                Text(store.text(tab.label)).font(ReadingFont.sans(12, bold: true))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .foregroundColor(Color(store.reading.tab == tab ? ChapterStyle.accent : ChapterStyle.secondary))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(store.reading.tab == tab ? .isSelected : [])
                        .accessibilityIdentifier("tab.\(tab.rawValue)")
                    }
                }.padding(.horizontal, 12).padding(.vertical, 8)
            }
            .background(Color(ChapterStyle.background).ignoresSafeArea())
            .foregroundColor(Color(ChapterStyle.primary))
            .background(NavigationLink(isActive: $showingReader) {
                ChapterReaderView(store: store, id: readerStory)
            } label: { EmptyView() }.hidden())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) { ReadingSettings(store: store) }
        }
        .navigationViewStyle(.stack)
        .tint(Color(ChapterStyle.accent))
    }

    private func open(_ id: StoryID) {
        store.open(id)
        readerStory = id
        showingReader = true
    }
}

private struct LibraryPage: View {
    @ObservedObject var store: ChapterStore
    let tab: LibraryTab
    let settings: () -> Void
    let open: (StoryID) -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill").foregroundColor(Color(ChapterStyle.accent))
                            Text(verbatim: "ReRune").foregroundColor(Color(ChapterStyle.primary))
                        }
                        .font(.custom("InstrumentSans-Bold", fixedSize: 27))
                        .lineLimit(1).minimumScaleFactor(0.6)
                        .accessibilityElement(children: .combine)
                        Spacer(minLength: 0)
                        LanguageMenu(store: store)
                        Button(action: settings) {
                            Image(systemName: "slider.horizontal.3").font(.system(size: 20))
                                .frame(width: 48, height: 48).background(Color(ChapterStyle.surface)).clipShape(Circle())
                        }
                        .foregroundColor(Color(ChapterStyle.secondary))
                        .accessibilityLabel(store.text(.reading_settings)).accessibilityIdentifier("settings")
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(store.text(title)).font(ReadingFont.sans(34, bold: true, relativeTo: .largeTitle))
                            .lineSpacing(2).fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                        Text(store.text(subtitle)).font(ReadingFont.sans(15))
                            .foregroundColor(Color(ChapterStyle.secondary)).fixedSize(horizontal: false, vertical: true)
                    }
                    if tab == .library {
                        if min(proxy.size.width - 48, ChapterStyle.libraryWidth) >= ChapterStyle.columnsAt {
                            HStack(alignment: .top, spacing: 32) {
                                featured.frame(maxWidth: .infinity)
                                recommendations.frame(maxWidth: .infinity)
                            }
                        } else { featured; recommendations }
                    } else {
                        if tab == .discover {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 135), alignment: .leading)], alignment: .leading, spacing: 12) {
                                ForEach(Genre.allCases) { genre in
                                    Button { store.selectGenre(genre) } label: {
                                        HStack(spacing: 6) {
                                            if store.reading.genre == genre { Image(systemName: "checkmark") }
                                            Text(store.text(genre.label)).fixedSize(horizontal: false, vertical: true)
                                        }.font(ReadingFont.sans(14)).padding(12).frame(maxWidth: .infinity, minHeight: 48)
                                            .background(Color(store.reading.genre == genre ? ChapterStyle.accent.withAlphaComponent(0.15) : ChapterStyle.surface))
                                            .clipShape(Capsule()).overlay(Capsule().stroke(Color(ChapterStyle.border)))
                                    }.buttonStyle(.plain)
                                        .foregroundColor(Color(store.reading.genre == genre ? ChapterStyle.brightAccent : ChapterStyle.primary))
                                        .accessibilityAddTraits(store.reading.genre == genre ? .isSelected : [])
                                        .accessibilityIdentifier("genre.\(genre.rawValue)")
                                }
                            }
                        }
                        if tab == .saved && store.reading.saved.isEmpty { emptyShelf }
                        ForEach(store.reading.stories(in: tab)) { id in
                            StoryCard(store: store, id: id, detailed: true, open: { open(id) })
                        }
                    }
                    RefreshTexts(store: store).frame(maxWidth: 360).frame(maxWidth: .infinity)
                    if tab == .library {
                        Text(store.text(.library_footer)).font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
                            .frame(maxWidth: .infinity).multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: ChapterStyle.libraryWidth).padding(24).frame(maxWidth: .infinity)
            }
            .refreshable { await store.refresh() }
            .accessibilityIdentifier("page.\(tab.rawValue)")
        }
    }

    private var title: ChapterKey { tab == .library ? .welcome_title : (tab == .discover ? .discover_title : .saved_title) }
    private var subtitle: ChapterKey { tab == .library ? .welcome_subtitle : (tab == .discover ? .discover_subtitle : .saved_subtitle) }

    private var featured: some View {
        VStack(spacing: 18) {
            HStack {
                Circle().fill(Color(ChapterStyle.accent)).frame(width: 5, height: 5)
                Text(store.text(.currently_reading))
                Spacer(minLength: 8)
                Text(store.text(.collection_issue))
            }.font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
            VStack(alignment: .leading, spacing: 8) {
                Text(store.text(store.reading.current.story.title)).font(ReadingFont.sans(29, relativeTo: .title))
                Text(store.text.story_by(author: store.reading.current.story.author)).font(ReadingFont.sans(13))
                Spacer(minLength: 72)
                BookmarkButton(store: store, id: store.reading.current, onCover: true)
            }
            .foregroundColor(Color(store.reading.current == .lantern ? ChapterStyle.primary : ChapterStyle.color(0x163A41)))
            .padding(22).frame(maxWidth: .infinity, minHeight: 245, alignment: .leading)
            .background(StoryCover(id: store.reading.current))
            ReadingProgress(store: store, id: store.reading.current)
            ReadingAction(title: store.text(.welcome_open_story_cta), symbol: "arrow.right") { open(store.reading.current) }
                .accessibilityIdentifier("continue")
        }
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(store.text(.next_chapter_shelf)).font(ReadingFont.sans(22, bold: true, relativeTo: .title2)).accessibilityAddTraits(.isHeader)
                Spacer(minLength: 8)
                Button(store.text(.see_all)) { store.selectTab(.discover) }
                    .font(ReadingFont.sans(14, bold: true)).foregroundColor(Color(ChapterStyle.accent)).frame(minHeight: 48)
            }
            ForEach(store.reading.stories(in: .library)) { id in
                StoryCard(store: store, id: id, detailed: false, open: { open(id) })
            }
            VStack(alignment: .leading, spacing: 12) {
                Text(store.text(.reading_moment)).font(ReadingFont.sans(12)).foregroundColor(Color(ChapterStyle.accent))
                Text(store.text(.reading_quote)).font(ReadingFont.serif(21)).fixedSize(horizontal: false, vertical: true)
            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(ChapterStyle.border)))
        }
    }

    private var emptyShelf: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark").font(.system(size: 36)).foregroundColor(Color(ChapterStyle.accent))
            Text(store.text(.saved_empty_title)).font(ReadingFont.sans(24, bold: true))
            Text(store.text(.saved_empty_body)).font(ReadingFont.sans(15)).foregroundColor(Color(ChapterStyle.secondary))
            ReadingAction(title: store.text(.explore_stories)) { store.selectTab(.discover) }
        }.multilineTextAlignment(.center).padding(24).frame(maxWidth: .infinity)
            .background(Color(ChapterStyle.surface)).clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

private struct StoryCard: View {
    @ObservedObject var store: ChapterStore
    let id: StoryID
    let detailed: Bool
    let open: () -> Void
    @Environment(\.sizeCategory) private var sizeCategory
    var body: some View {
        HStack(spacing: 8) {
            Button(action: open) {
                HStack(spacing: 14) {
                    if !sizeCategory.isAccessibilityCategory {
                        StoryCover(id: id).frame(width: detailed ? 88 : 70, height: detailed ? 118 : 100)
                    }
                    VStack(alignment: .leading, spacing: 7) {
                        Text(store.text(id.story.genre.label)).font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.brightAccent))
                        Text(store.text(id.story.title)).font(ReadingFont.sans(17, bold: true)).foregroundColor(Color(ChapterStyle.primary))
                        Text(id.story.author).font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
                        if detailed {
                            Text(store.text(id.story.description)).font(ReadingFont.sans(15))
                                .foregroundColor(Color(ChapterStyle.secondary)).lineSpacing(4)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading).fixedSize(horizontal: false, vertical: true)
                }
            }.buttonStyle(.plain).accessibilityIdentifier("story.\(id.rawValue)")
            BookmarkButton(store: store, id: id)
        }.padding(12).background(Color(ChapterStyle.surface)).clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
