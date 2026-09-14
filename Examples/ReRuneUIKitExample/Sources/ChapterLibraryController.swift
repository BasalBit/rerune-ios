import Combine
import UIKit

final class ChapterLibraryController: UIViewController {
    private let store: ChapterStore
    private var pages: [LibraryTab: LibraryPageController] = [:]
    private var buttons: [LibraryTab: UIButton] = [:]
    private var subscription: AnyCancellable?
    init(store: ChapterStore) { self.store = store; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChapterStyle.background
        let container = UIView(), tabs = ChapterViews.stack(spacing: 0, horizontal: true)
        container.translatesAutoresizingMaskIntoConstraints = false; tabs.translatesAutoresizingMaskIntoConstraints = false
        tabs.distribution = .fillEqually
        view.addSubview(container); view.addSubview(tabs)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor), container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: tabs.topAnchor),
            tabs.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            tabs.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            tabs.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabs.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        for tab in LibraryTab.allCases {
            let page = LibraryPageController(store: store, pageTab: tab)
            pages[tab] = page
            addChild(page); page.view.translatesAutoresizingMaskIntoConstraints = false; container.addSubview(page.view)
            NSLayoutConstraint.activate([
                page.view.topAnchor.constraint(equalTo: container.topAnchor), page.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                page.view.leadingAnchor.constraint(equalTo: container.leadingAnchor), page.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
            page.didMove(toParent: self)
            let button = ChapterViews.button { [weak store] in store?.selectTab(tab) }
            button.configuration?.imagePlacement = .top
            button.configuration?.imagePadding = 5
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes; attributes.font = ChapterStyle.font(12, bold: true); return attributes
            }
            button.accessibilityIdentifier = "tab.\(tab.rawValue)"
            tabs.addArrangedSubview(button); buttons[tab] = button
        }
        subscription = store.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.update() }
        update()
    }
    private func update() {
        for tab in LibraryTab.allCases {
            let selected = tab == store.reading.tab
            pages[tab]?.view.isHidden = !selected
            buttons[tab]?.configuration?.title = store.text(tab.label)
            buttons[tab]?.configuration?.image = UIImage(systemName: tab.symbol + (selected ? ".fill" : ""))
            buttons[tab]?.configuration?.baseForegroundColor = selected ? ChapterStyle.accent : ChapterStyle.secondary
            buttons[tab]?.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }
}

private final class LibraryPageController: ChapterController {
    private let pageTab: LibraryTab
    private let columns = ChapterViews.stack(spacing: 32)
    private var cards: [StoryID: StoryCardView] = [:]
    private var filterButtons: [Genre: UIButton] = [:]
    private var emptyShelf: UIView?
    private let refreshControl = UIRefreshControl()

    init(store: ChapterStore, pageTab: LibraryTab) {
        self.pageTab = pageTab; super.init(store: store)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.accessibilityIdentifier = "page.\(pageTab.rawValue)"
        scrollView.refreshControl = refreshControl
        refreshControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Task { await self.store.refresh(); self.refreshControl.endRefreshing() }
        }, for: .valueChanged)
        addHeader()
        let titleKey: ChapterKey = pageTab == .library ? .welcome_title : (pageTab == .discover ? .discover_title : .saved_title)
        let subtitleKey: ChapterKey = pageTab == .library ? .welcome_subtitle : (pageTab == .discover ? .discover_subtitle : .saved_subtitle)
        let heading = text(titleKey, size: 34, bold: true); heading.accessibilityTraits.insert(.header)
        content.addArrangedSubview(ChapterViews.stack([heading, text(subtitleKey, color: ChapterStyle.secondary)], spacing: 10))
        if pageTab == .library {
            columns.addArrangedSubview(featured())
            columns.addArrangedSubview(recommendations())
            content.addArrangedSubview(columns)
        } else {
            if pageTab == .discover { addFilters() }
            if pageTab == .saved {
                let empty = makeEmptyShelf(); emptyShelf = empty; content.addArrangedSubview(empty)
            }
            for id in StoryID.allCases {
                let card = makeCard(id, detailed: true); cards[id] = card; content.addArrangedSubview(card)
            }
        }
        content.addArrangedSubview(RefreshPanel(store: store))
        if pageTab == .library {
            let footer = text(.library_footer, size: 13, color: ChapterStyle.secondary); footer.textAlignment = .center
            content.addArrangedSubview(footer)
        }
        rebind()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let wide = content.bounds.width >= ChapterStyle.columnsAt
        if (columns.axis == .horizontal) != wide {
            columns.axis = wide ? .horizontal : .vertical
            columns.distribution = wide ? .fillEqually : .fill
            columns.alignment = wide ? .top : .fill
        }
    }
    override func rebind() {
        super.rebind()
        let visible = store.reading.stories(in: pageTab)
        for (id, card) in cards { card.isHidden = !visible.contains(id); card.update() }
        emptyShelf?.isHidden = !store.reading.saved.isEmpty
        for (genre, button) in filterButtons {
            let selected = genre == store.reading.genre
            button.configuration?.title = store.text(genre.label)
            button.configuration?.image = selected ? UIImage(systemName: "checkmark") : nil
            button.configuration?.baseForegroundColor = selected ? ChapterStyle.brightAccent : ChapterStyle.primary
            button.backgroundColor = selected ? ChapterStyle.accent.withAlphaComponent(0.15) : ChapterStyle.surface
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }
    private func addHeader() {
        let mark = ChapterViews.label(27, bold: true); mark.text = "ReRune"; mark.numberOfLines = 1
        mark.font = UIFont(name: "InstrumentSans-Bold", size: 27)
        mark.adjustsFontForContentSizeCategory = false
        mark.adjustsFontSizeToFitWidth = true; mark.minimumScaleFactor = 0.6
        mark.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let icon = UIImageView(image: UIImage(systemName: "book.fill")); icon.tintColor = ChapterStyle.accent
        icon.contentMode = .scaleAspectFit; icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        let settings = ChapterViews.button(symbol: "slider.horizontal.3") { [weak self] in
            guard let self else { return }
            let controller = ReadingSettingsController(store: self.store)
            controller.modalPresentationStyle = .pageSheet
            controller.sheetPresentationController?.detents = [.medium(), .large()]
            controller.sheetPresentationController?.prefersGrabberVisible = true
            self.present(controller, animated: !UIAccessibility.isReduceMotionEnabled)
        }
        settings.backgroundColor = ChapterStyle.surface; settings.layer.cornerRadius = 24
        settings.widthAnchor.constraint(equalToConstant: 48).isActive = true
        settings.accessibilityIdentifier = "settings"
        bind { [weak store, weak settings] in settings?.accessibilityLabel = store?.text(.reading_settings) }
        let header = ChapterViews.stack([icon, mark, languageMenu(), settings], spacing: 8, horizontal: true)
        header.alignment = .center
        content.addArrangedSubview(header)
    }
    private func featured() -> UIView {
        let issue = text(.collection_issue, size: 13, color: ChapterStyle.secondary)
        issue.setContentHuggingPriority(.required, for: .horizontal)
        let dot = ChapterViews.label(13, color: ChapterStyle.accent); dot.text = "•"
        dot.setContentHuggingPriority(.required, for: .horizontal)
        let heading = ChapterViews.stack([dot, text(.currently_reading, size: 13, color: ChapterStyle.secondary), issue], spacing: 8, horizontal: true)
        heading.alignment = .firstBaseline
        let art = CoverView(store.reading.current)
        let title = ChapterViews.label(29), byline = ChapterViews.label(13)
        let spacer = UIView(); spacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
        let save = bookmark({ [weak store] in store?.reading.current ?? .atlas }, onCover: true)
        let saveRow = ChapterViews.stack([save, UIView()], spacing: 0, horizontal: true)
        let overlay = ChapterViews.stack([title, byline, spacer, saveRow], spacing: 8)
        let inset = ChapterViews.inset(overlay, amount: 22)
        inset.translatesAutoresizingMaskIntoConstraints = false; art.addSubview(inset)
        NSLayoutConstraint.activate([
            art.heightAnchor.constraint(greaterThanOrEqualToConstant: 245),
            inset.topAnchor.constraint(equalTo: art.topAnchor), inset.bottomAnchor.constraint(equalTo: art.bottomAnchor),
            inset.leadingAnchor.constraint(equalTo: art.leadingAnchor), inset.trailingAnchor.constraint(equalTo: art.trailingAnchor)
        ])
        let progress = ProgressPanel()
        bind { [weak store, weak art, weak title, weak byline, weak progress] in
            guard let store else { return }
            let id = store.reading.current
            art?.story = id; title?.text = store.text(id.story.title); byline?.text = store.text.story_by(author: id.story.author)
            let color = id == .lantern ? ChapterStyle.primary : ChapterStyle.color(0x163A41)
            title?.textColor = color; byline?.textColor = color
            progress?.update(store, id)
        }
        let next = action(.welcome_open_story_cta, symbol: "arrow.right", primary: true) { [weak self] in
            guard let self else { return }; self.open(self.store.reading.current)
        }
        next.configuration?.imagePlacement = .trailing; next.accessibilityIdentifier = "continue"
        return ChapterViews.stack([heading, art, progress, next], spacing: 18)
    }
    private func recommendations() -> UIView {
        let title = text(.next_chapter_shelf, size: 22, bold: true); title.accessibilityTraits.insert(.header)
        let all = action(.see_all) { [weak store] in store?.selectTab(.discover) }
        all.configuration?.baseForegroundColor = ChapterStyle.accent
        let row = ChapterViews.stack([title, all], spacing: 8, horizontal: true); row.alignment = .center
        let stack = ChapterViews.stack([row], spacing: 16)
        for id in StoryID.allCases {
            let card = makeCard(id, detailed: false); cards[id] = card; stack.addArrangedSubview(card)
        }
        let quote = ChapterViews.inset(ChapterViews.stack([
            text(.reading_moment, size: 12, color: ChapterStyle.accent), text(.reading_quote, size: 21, serif: true)
        ], spacing: 12), amount: 20)
        quote.layer.borderWidth = 1; quote.layer.borderColor = ChapterStyle.border.cgColor
        stack.addArrangedSubview(quote)
        return stack
    }
    private func makeCard(_ id: StoryID, detailed: Bool) -> StoryCardView {
        StoryCardView(store: store, id: id, detailed: detailed) { [weak self] in self?.open(id) }
    }
    private func open(_ id: StoryID) {
        store.open(id)
        navigationController?.pushViewController(ChapterReaderController(store: store, id: id), animated: !UIAccessibility.isReduceMotionEnabled)
    }
    private func addFilters() {
        // Rows grow with Dynamic Type; every filter remains reachable on narrow phones.
        let filters = ChapterViews.stack(spacing: 12)
        for pair in [[Genre.all, .wonder], [.adventure, .nature]] {
            let row = ChapterViews.stack(spacing: 8, horizontal: true); row.distribution = .fillEqually
            for genre in pair {
                let button = ChapterViews.button { [weak store] in store?.selectGenre(genre) }
                button.layer.cornerRadius = 24; button.layer.borderWidth = 1; button.layer.borderColor = ChapterStyle.border.cgColor
                button.accessibilityIdentifier = "genre.\(genre.rawValue)"
                row.addArrangedSubview(button); filterButtons[genre] = button
            }
            filters.addArrangedSubview(row)
        }
        content.addArrangedSubview(filters)
    }
    private func makeEmptyShelf() -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "bookmark")); icon.tintColor = ChapterStyle.accent
        icon.contentMode = .scaleAspectFit; icon.heightAnchor.constraint(equalToConstant: 48).isActive = true
        let title = text(.saved_empty_title, size: 24, bold: true), body = text(.saved_empty_body, color: ChapterStyle.secondary)
        title.textAlignment = .center; body.textAlignment = .center
        let button = action(.explore_stories, primary: true) { [weak store] in store?.selectTab(.discover) }
        return ChapterViews.inset(ChapterViews.stack([icon, title, body, button], spacing: 20), amount: 24, background: ChapterStyle.surface)
    }
}
