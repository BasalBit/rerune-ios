import UIKit

final class ChapterReaderController: ChapterController {
    private let id: StoryID
    private var lastCompleted: Int
    private let chapterTitle = ChapterViews.label(30, serif: true)
    private let byline = ChapterViews.label(13, color: ChapterStyle.secondary)
    private let paragraphs = [ChapterViews.label(19, serif: true, color: ChapterStyle.prose), ChapterViews.label(19, serif: true, color: ChapterStyle.prose)]
    private let prose = ChapterViews.stack(spacing: 26)
    private var ending: UIView?
    private let progress = ProgressPanel()
    private var advance: UIButton?
    override var maximumWidth: CGFloat { ChapterStyle.readerWidth }

    init(store: ChapterStore, id: StoryID) {
        self.id = id; lastCompleted = store.reading.completed(id)
        super.init(store: store)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        let back = ChapterViews.button(symbol: "arrow.left") { [weak self] in
            self?.navigationController?.popViewController(animated: !UIAccessibility.isReduceMotionEnabled)
        }
        back.widthAnchor.constraint(equalToConstant: 48).isActive = true
        bind { [weak store, weak back] in back?.accessibilityLabel = store?.text(.back_library) }
        let title = text(id.story.title, size: 16, bold: true); title.textAlignment = .center
        let header = ChapterViews.stack([back, title, languageMenu()], spacing: 8, horizontal: true); header.alignment = .center
        // Move the scroll view below a fixed native reader header.
        view.constraints.filter { $0.firstItem === scrollView && $0.firstAttribute == .top }.forEach { $0.isActive = false }
        header.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor)
        ])
        let cover = CoverView(id); cover.heightAnchor.constraint(equalToConstant: 200).isActive = true
        let save = bookmark({ [id] in id }, onCover: true)
        save.translatesAutoresizingMaskIntoConstraints = false; cover.addSubview(save)
        NSLayoutConstraint.activate([save.trailingAnchor.constraint(equalTo: cover.trailingAnchor, constant: -14),
                                     save.bottomAnchor.constraint(equalTo: cover.bottomAnchor, constant: -14)])
        content.addArrangedSubview(cover); content.addArrangedSubview(progress)
        chapterTitle.accessibilityTraits.insert(.header)
        prose.addArrangedSubview(ChapterViews.stack([chapterTitle, byline], spacing: 12))
        paragraphs.forEach { prose.addArrangedSubview($0) }
        let advance = ChapterViews.button(symbol: "arrow.right", primary: true) { [weak self] in
            guard let self else { return }; self.store.finishChapter(self.id)
        }
        advance.configuration?.imagePlacement = .trailing; advance.accessibilityIdentifier = "chapter.advance"
        self.advance = advance; prose.addArrangedSubview(advance); content.addArrangedSubview(prose)
        let end = makeEnding(); ending = end; content.addArrangedSubview(end)
        content.addArrangedSubview(RefreshPanel(store: store))
        rebind()
    }
    override func rebind() {
        super.rebind()
        progress.update(store, id)
        let finished = store.reading.isFinished(id)
        prose.isHidden = finished; ending?.isHidden = !finished
        let chapter = id.story.chapters[store.reading.chapterIndex(id)]
        chapterTitle.text = store.text(chapter.title)
        byline.text = store.text.story_by(author: id.story.author)
        for (label, key) in zip(paragraphs, chapter.paragraphs) {
            let style = NSMutableParagraphStyle(); style.lineSpacing = UIFontMetrics.default.scaledValue(for: 12)
            label.attributedText = NSAttributedString(string: store.text(key), attributes: [.paragraphStyle: style])
        }
        advance?.configuration?.title = store.text(store.reading.chapterIndex(id) == 0 ? .next_chapter : .finish_story)
        if lastCompleted != store.reading.completed(id) {
            lastCompleted = store.reading.completed(id)
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: false)
            UIAccessibility.post(notification: .screenChanged, argument: finished ? ending : chapterTitle)
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if isViewLoaded { rebind() }
    }
    private func makeEnding() -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "book.fill")); icon.tintColor = ChapterStyle.accent
        icon.contentMode = .scaleAspectFit; icon.heightAnchor.constraint(equalToConstant: 48).isActive = true
        let title = text(.reader_end_title, size: 28, bold: true), body = text(.reader_end_body, color: ChapterStyle.secondary)
        title.textAlignment = .center; title.accessibilityTraits.insert(.header); body.textAlignment = .center
        let again = action(.read_again, primary: true) { [weak self] in
            guard let self else { return }; self.store.restart(self.id)
        }
        again.accessibilityIdentifier = "read.again"
        return ChapterViews.stack([icon, title, body, again], spacing: 24)
    }
}
