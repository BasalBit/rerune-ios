import UIKit
import ReRune

final class StoryViewController: UIViewController, ReRuneTextRefreshable {
    private let backgroundView = DemoBackgroundView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let heroImageView = UIImageView(image: UIImage(named: "blacksmith"))
    private let titleLabel = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 34, weight: .bold),
        color: DemoTheme.textPrimary,
        lines: 0
    )
    private let bodyPrimaryLabel = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 17, weight: .medium),
        color: DemoTheme.textPrimary,
        lines: 0
    )
    private let bodySecondaryLabel = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 16, weight: .regular),
        color: DemoTheme.textSecondary,
        lines: 0
    )
    private let captionChip = BadgeChipView()
    private let refreshButton = UIButton.demoAccentButton()

    private var isRefreshing = false {
        didSet {
            updateRefreshButtonState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = DemoTheme.bgPrimary
        setupViews()
        rebindStrings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func rebindStrings() {
        titleLabel.text = localized("story_title")
        bodyPrimaryLabel.text = localized("story_body_primary")
        bodySecondaryLabel.text = localized("story_body_secondary")
        captionChip.update(title: localized("story_caption"))
        updateRefreshButtonState()
    }

    @objc
    private func refreshTexts() {
        guard !isRefreshing else { return }

        Task {
            await MainActor.run {
                isRefreshing = true
            }
            _ = await reRuneCheckForUpdates()
            await MainActor.run {
                isRefreshing = false
            }
        }
    }

    private func setupViews() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        backgroundView.pinEdges(to: view)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        contentView.addSubview(stackView)

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.layer.cornerRadius = 32
        heroImageView.layer.cornerCurve = .continuous
        heroImageView.layer.borderWidth = 1
        heroImageView.layer.borderColor = DemoTheme.borderSubtle.cgColor
        heroImageView.heightAnchor.constraint(equalToConstant: 360).isActive = true

        bodyPrimaryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bodySecondaryLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyPrimaryLabel, bodySecondaryLabel, captionChip])
        textStack.axis = .vertical
        textStack.spacing = 16
        textStack.translatesAutoresizingMaskIntoConstraints = false

        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshTexts), for: .touchUpInside)

        stackView.addArrangedSubview(heroImageView)
        stackView.addArrangedSubview(textStack)
        stackView.addArrangedSubview(refreshButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DemoTheme.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DemoTheme.horizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28),
        ])
    }

    private func updateRefreshButtonState() {
        refreshButton.setTitle(localized("story_refresh_cta"), for: .normal)
        refreshButton.isEnabled = !isRefreshing

        if isRefreshing {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = DemoTheme.bgPrimary
            indicator.startAnimating()
            refreshButton.configuration = nil
            refreshButton.setImage(nil, for: .normal)
            refreshButton.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
            indicator.translatesAutoresizingMaskIntoConstraints = false
            refreshButton.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor),
                indicator.leadingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: 20),
            ])
            refreshButton.contentHorizontalAlignment = .center
            refreshButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        } else {
            refreshButton.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
            refreshButton.titleEdgeInsets = .zero
        }
    }

    private func localized(_ key: String) -> String {
        if key == "welcome_title" || key == "story_title" {
            return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        }

        return NSLocalizedString(key, comment: "")
    }
}
