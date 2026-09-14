import Combine
import UIKit

final class CoverView: UIView {
    var story: StoryID { didSet { setNeedsDisplay() } }
    init(_ story: StoryID) {
        self.story = story
        super.init(frame: .zero)
        isOpaque = true
        layer.cornerRadius = ChapterStyle.radius
        clipsToBounds = true
        contentMode = .redraw
        isAccessibilityElement = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        CoverArtwork.draw(story, in: context, size: bounds.size)
    }
}

enum ChapterViews {
    static func stack(_ views: [UIView] = [], spacing: CGFloat = 16, horizontal: Bool = false) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = horizontal ? .horizontal : .vertical
        stack.spacing = spacing
        return stack
    }
    static func label(_ size: CGFloat = 15, bold: Bool = false, serif: Bool = false,
                      color: UIColor = ChapterStyle.primary) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let style: UIFont.TextStyle = size >= 34 ? .largeTitle : (size >= 28 ? .title1 : (size >= 22 ? .title2 : .body))
        label.font = ChapterStyle.font(size, bold: bold, serif: serif, style: style)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }
    static func button(symbol: String? = nil, primary: Bool = false, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        var config = primary ? UIButton.Configuration.filled() : .plain()
        config.baseBackgroundColor = primary ? ChapterStyle.accent : .clear
        config.baseForegroundColor = primary ? ChapterStyle.background : ChapterStyle.secondary
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        config.imagePadding = 10
        config.image = symbol.flatMap { UIImage(systemName: $0) }
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = ChapterStyle.font(16, bold: true)
            return attributes
        }
        button.configuration = config
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: primary ? 52 : 48).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
    static func inset(_ content: UIView, amount: CGFloat, background: UIColor? = nil) -> UIView {
        let view = UIView()
        view.backgroundColor = background
        view.layer.cornerRadius = ChapterStyle.radius
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.topAnchor, constant: amount),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -amount),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: amount),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -amount)
        ])
        return view
    }
}

final class ProgressPanel: UIStackView {
    private let titleLabel = ChapterViews.label(14, bold: true)
    private let percentage = ChapterViews.label(13, color: ChapterStyle.secondary)
    private let bar = UIProgressView(progressViewStyle: .bar)
    init() {
        super.init(frame: .zero)
        axis = .vertical; spacing = 12
        let row = ChapterViews.stack([titleLabel, percentage], spacing: 12, horizontal: true)
        row.alignment = .firstBaseline
        percentage.setContentHuggingPriority(.required, for: .horizontal)
        addArrangedSubview(row); addArrangedSubview(bar)
        bar.progressTintColor = ChapterStyle.accent; bar.trackTintColor = ChapterStyle.border
        bar.heightAnchor.constraint(equalToConstant: 4).isActive = true
        isAccessibilityElement = true
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func update(_ store: ChapterStore, _ id: StoryID) {
        titleLabel.text = store.progressLabel(id)
        percentage.text = store.reading.progress(id).formatted(.percent.precision(.fractionLength(0)))
        bar.setProgress(Float(store.reading.progress(id)), animated: false)
        accessibilityLabel = titleLabel.text; accessibilityValue = percentage.text
        accessibilityIdentifier = "progress.\(id.rawValue)"
    }
}

final class RefreshPanel: UIStackView {
    private let store: ChapterStore
    private lazy var button = ChapterViews.button(symbol: "arrow.clockwise") { [weak self] in
        guard let self else { return }
        Task { await self.store.refresh() }
    }
    private let result = ChapterViews.label(13, color: ChapterStyle.secondary)
    private var subscription: AnyCancellable?
    init(store: ChapterStore) {
        self.store = store
        super.init(frame: .zero)
        axis = .vertical; spacing = 12
        button.layer.cornerRadius = 16; button.layer.borderWidth = 1; button.layer.borderColor = ChapterStyle.border.cgColor
        button.accessibilityIdentifier = "refresh"
        result.textAlignment = .center; result.accessibilityIdentifier = "refresh.result"
        addArrangedSubview(button); addArrangedSubview(result)
        subscription = store.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.update() }
        update()
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func update() {
        button.configuration?.title = store.text(.story_refresh_cta)
        button.configuration?.showsActivityIndicator = store.refreshState == .busy
        button.isEnabled = store.refreshState != .busy && !store.changingVariant
        result.isHidden = store.refreshState.label == nil
        result.text = store.refreshState.label.map { store.text($0) }
        result.textColor = store.refreshState == .failed ? .systemRed : ChapterStyle.secondary
    }
}

final class StoryCardView: UIView {
    private let store: ChapterStore
    private let id: StoryID
    private let art: CoverView
    private let genre = ChapterViews.label(13, color: ChapterStyle.brightAccent)
    private let titleLabel = ChapterViews.label(17, bold: true)
    private let author = ChapterViews.label(13, color: ChapterStyle.secondary)
    private let summary = ChapterViews.label(15, color: ChapterStyle.secondary)
    private let bookmark: UIButton

    init(store: ChapterStore, id: StoryID, detailed: Bool, open: @escaping () -> Void) {
        self.store = store; self.id = id
        art = CoverView(id)
        bookmark = ChapterViews.button { [weak store] in store?.toggleSaved(id) }
        super.init(frame: .zero)
        backgroundColor = ChapterStyle.surface; layer.cornerRadius = ChapterStyle.radius
        let text = ChapterViews.stack([genre, titleLabel, author] + (detailed ? [summary] : []), spacing: 7)
        let body = ChapterViews.stack([art, text], spacing: 14, horizontal: true); body.alignment = .center
        let artWidth = art.widthAnchor.constraint(equalToConstant: detailed ? 88 : 70)
        // UIStackView sets a hidden arranged view's width to zero at required
        // priority when accessibility text replaces the decorative thumbnail.
        artWidth.priority = UILayoutPriority(999)
        artWidth.isActive = true
        art.heightAnchor.constraint(equalToConstant: detailed ? 118 : 100).isActive = true
        let openButton = UIButton(type: .custom)
        openButton.addAction(UIAction { _ in open() }, for: .touchUpInside)
        body.isUserInteractionEnabled = false
        body.translatesAutoresizingMaskIntoConstraints = false
        openButton.addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: openButton.topAnchor), body.bottomAnchor.constraint(equalTo: openButton.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: openButton.leadingAnchor), body.trailingAnchor.constraint(equalTo: openButton.trailingAnchor)
        ])
        openButton.accessibilityIdentifier = "story.\(id.rawValue)"
        openButton.accessibilityLabel = store.text(id.story.title)
        bookmark.accessibilityIdentifier = "bookmark.\(id.rawValue)"
        bookmark.widthAnchor.constraint(equalToConstant: 48).isActive = true
        let row = ChapterViews.stack([openButton, bookmark], spacing: 8, horizontal: true); row.alignment = .center
        let inset = ChapterViews.inset(row, amount: 12)
        inset.translatesAutoresizingMaskIntoConstraints = false; addSubview(inset)
        NSLayoutConstraint.activate([
            inset.topAnchor.constraint(equalTo: topAnchor), inset.bottomAnchor.constraint(equalTo: bottomAnchor),
            inset.leadingAnchor.constraint(equalTo: leadingAnchor), inset.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        self.openButton = openButton
        art.isHidden = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        update()
    }
    private weak var openButton: UIButton?
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        art.isHidden = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    }
    func update() {
        genre.text = store.text(id.story.genre.label); titleLabel.text = store.text(id.story.title)
        author.text = id.story.author; summary.text = store.text(id.story.description)
        openButton?.accessibilityLabel = [genre.text, titleLabel.text, author.text, summary.text].compactMap { $0 }.joined(separator: ". ")
        bookmark.configuration?.image = UIImage(systemName: store.reading.saved.contains(id) ? "bookmark.fill" : "bookmark")
        bookmark.accessibilityLabel = store.text(store.reading.saved.contains(id) ? .remove_saved : .save_story)
        bookmark.accessibilityValue = store.text(id.story.title)
    }
}
