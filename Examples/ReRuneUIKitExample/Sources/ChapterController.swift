import Combine
import UIKit

class ChapterController: UIViewController {
    let store: ChapterStore
    let scrollView = UIScrollView()
    let content = ChapterViews.stack(spacing: 28)
    var maximumWidth: CGFloat { ChapterStyle.libraryWidth }
    private var bindings: [() -> Void] = []
    private var subscription: AnyCancellable?

    init(store: ChapterStore) { self.store = store; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChapterStyle.background
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView); scrollView.addSubview(content)
        let gutter = ChapterStyle.gutter
        let width = content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * gutter)
        // Fill the viewport before honoring intrinsic text widths. Only the
        // required reading-width cap may reduce this on larger windows.
        width.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: gutter),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -gutter),
            content.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            content.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.leadingAnchor, constant: gutter),
            content.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -gutter),
            content.widthAnchor.constraint(lessThanOrEqualToConstant: maximumWidth), width,
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        subscription = store.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.rebind() }
    }

    func bind(_ update: @escaping () -> Void) { bindings.append(update); update() }
    func rebind() { bindings.forEach { $0() } }

    func text(_ key: ChapterKey, size: CGFloat = 15, bold: Bool = false, serif: Bool = false,
              color: UIColor = ChapterStyle.primary) -> UILabel {
        let label = ChapterViews.label(size, bold: bold, serif: serif, color: color)
        bind { [weak store, weak label] in label?.text = store?.text(key) }
        return label
    }

    func action(_ key: ChapterKey, symbol: String? = nil, primary: Bool = false,
                perform: @escaping () -> Void) -> UIButton {
        let button = ChapterViews.button(symbol: symbol, primary: primary, action: perform)
        bind { [weak store, weak button] in button?.configuration?.title = store?.text(key) }
        return button
    }

    func languageMenu() -> UIButton {
        let button = ChapterViews.button(symbol: "globe") {}
        button.titleLabel?.numberOfLines = 1
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        button.showsMenuAsPrimaryAction = true
        button.accessibilityIdentifier = "language"
        bind { [weak store, weak button] in
            guard let store, let button else { return }
            button.configuration?.title = store.locale.split(separator: "-").first.map(String.init)?.uppercased() ?? store.locale
            button.accessibilityLabel = store.text(.welcome_locale_label); button.accessibilityValue = store.locale
            button.menu = UIMenu(children: store.locales.map { locale in
                UIAction(title: locale.name, state: store.locale == locale.code ? .on : .off) { [weak store] _ in store?.selectLocale(locale.code) }
            })
        }
        return button
    }

    func bookmark(_ id: @escaping () -> StoryID, onCover: Bool = false) -> UIButton {
        let button = ChapterViews.button { [weak store] in store?.toggleSaved(id()) }
        button.widthAnchor.constraint(equalToConstant: 48).isActive = true
        if onCover { button.backgroundColor = ChapterStyle.background.withAlphaComponent(0.88); button.layer.cornerRadius = 24 }
        bind { [weak store, weak button] in
            guard let store, let button else { return }
            let story = id(), saved = store.reading.saved.contains(story)
            button.configuration?.image = UIImage(systemName: saved ? "bookmark.fill" : "bookmark")
            button.configuration?.baseForegroundColor = ChapterStyle.primary
            button.accessibilityLabel = store.text(saved ? .remove_saved : .save_story)
            button.accessibilityValue = store.text(story.story.title)
            button.accessibilityIdentifier = "bookmark.\(story.rawValue)"
        }
        return button
    }
}
