import UIKit
import ReRune

final class WelcomeViewController: UIViewController, ReRuneTextRefreshable {
    private enum RefreshPhase {
        case idle
        case checking
        case downloading
        case applying
        case success

        var localizationKey: String {
            switch self {
            case .idle:
                return "welcome_refresh_state_idle"
            case .checking:
                return "welcome_refresh_state_checking"
            case .downloading:
                return "welcome_refresh_state_downloading"
            case .applying:
                return "welcome_refresh_state_applying"
            case .success:
                return "welcome_refresh_state_success"
            }
        }

        var tint: UIColor {
            switch self {
            case .success:
                return DemoTheme.success
            case .idle:
                return DemoTheme.textSecondary
            case .checking, .downloading, .applying:
                return DemoTheme.accentPrimary
            }
        }
    }

    private let backgroundView = DemoBackgroundView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStack = UIStackView()
    private let headerStack = UIStackView()
    private let footerStack = UIStackView()
    private let topSpacer = UIView()
    private let bottomSpacer = UIView()
    private let badgeView = BadgeChipView()
    private let titleLabel = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 36, weight: .bold),
        color: DemoTheme.textPrimary,
        lines: 0
    )
    private let subtitleLabel = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 17, weight: .medium),
        color: DemoTheme.textSecondary,
        lines: 0
    )
    private let heroImageView = UIImageView(image: UIImage(named: "writer_orb"))
    private let statusCardView = StatusCardView()
    private let refreshStateLabel = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 14, weight: .semibold),
        color: DemoTheme.textSecondary,
        lines: 0
    )
    private let openStoryButton = UIButton.demoPrimaryButton()
    private let refreshControl = UIRefreshControl()

    private var heroHeightConstraint: NSLayoutConstraint?
    private var refreshPhase: RefreshPhase = .idle
    private var lastSyncedText = WelcomeViewController.formattedTimestamp(for: Date())

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = DemoTheme.bgPrimary
        navigationItem.backButtonDisplayMode = .minimal
        setupViews()
        rebindStrings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroHeightConstraint?.constant = heroHeight(for: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        openStoryButton.updatePrimaryGradientFrame()
    }

    func rebindStrings() {
        badgeView.update(title: localized("welcome_badge"))
        titleLabel.text = localized("welcome_title")
        subtitleLabel.text = localized("welcome_subtitle")
        statusCardView.update(rows: [
            (label: localized("welcome_locale_label"), value: localized("welcome_locale_value")),
            (label: localized("welcome_last_synced_label"), value: lastSyncedText),
        ])
        refreshStateLabel.text = localized(refreshPhase.localizationKey)
        refreshStateLabel.textColor = refreshPhase.tint
        openStoryButton.setTitle(localized("welcome_open_story_cta"), for: .normal)
    }

    @objc
    private func openStory() {
        navigationController?.pushViewController(StoryViewController(), animated: true)
    }

    @objc
    private func pullToRefresh() {
        Task {
            await MainActor.run {
                updateRefreshPhase(.checking)
            }
            try? await Task.sleep(nanoseconds: 350_000_000)

            await MainActor.run {
                updateRefreshPhase(.downloading)
            }
            let result = await reRuneCheckForUpdates()

            await MainActor.run {
                updateRefreshPhase(.applying)
            }
            try? await Task.sleep(nanoseconds: 300_000_000)

            await MainActor.run {
                lastSyncedText = Self.formattedTimestamp(for: Date())
                refreshPhase = result.status == .updated ? .success : .idle
                refreshControl.endRefreshing()
                rebindStrings()
            }
        }
    }

    private func updateRefreshPhase(_ phase: RefreshPhase) {
        refreshPhase = phase
        rebindStrings()
    }

    private func setupViews() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        backgroundView.pinEdges(to: view)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.refreshControl = refreshControl
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentView.addSubview(contentStack)

        headerStack.axis = .vertical
        headerStack.spacing = 18
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.addArrangedSubview(badgeView)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subtitleLabel)
        headerStack.setCustomSpacing(0, after: badgeView)
        badgeView.setContentHuggingPriority(.required, for: .horizontal)

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroHeightConstraint = heroImageView.heightAnchor.constraint(equalToConstant: 320)
        heroHeightConstraint?.isActive = true

        footerStack.axis = .vertical
        footerStack.spacing = 14
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.addArrangedSubview(statusCardView)
        footerStack.addArrangedSubview(refreshStateLabel)

        [topSpacer, bottomSpacer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        }

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(topSpacer)
        contentStack.addArrangedSubview(heroImageView)
        contentStack.addArrangedSubview(bottomSpacer)
        contentStack.addArrangedSubview(footerStack)
        contentStack.addArrangedSubview(openStoryButton)

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        refreshStateLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        openStoryButton.addTarget(self, action: #selector(openStory), for: .touchUpInside)

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
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DemoTheme.horizontalPadding),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DemoTheme.horizontalPadding),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28),
        ])
    }

    private func heroHeight(for availableHeight: CGFloat) -> CGFloat {
        min(max(availableHeight * 0.34, 300), 460)
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static func formattedTimestamp(for date: Date) -> String {
        timestampFormatter.string(from: date)
    }

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
