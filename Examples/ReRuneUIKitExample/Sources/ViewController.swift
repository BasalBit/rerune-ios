import UIKit
import ReRune

final class ViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let placeholderLabel = UILabel()
    private let redrawLabel = UILabel()
    private let inputField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let applyButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let refreshControl = UIRefreshControl()

    private var lastRedraw = ViewController.currentTimestamp()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutViews()
        rebindStrings()
    }

    func rebindStrings() {
        navigationItem.title = "ReRune"
        titleLabel.text = reRuneString("title")
        subtitleLabel.text = reRuneString("body")
        placeholderLabel.text = formattedString("sample_placeholder", [1, "RubinTXT"])
        redrawLabel.text = formattedString("last_redraw", [lastRedraw])
        inputField.placeholder = reRuneString("input_hint")
        inputField.accessibilityLabel = reRuneString("input_content_description")
        checkButton.setTitle(reRuneString("button"), for: .normal)
        checkButton.accessibilityLabel = reRuneString("check_updates_content_description")
        applyButton.setTitle(reRuneString("apply_programmatic_texts_button"), for: .normal)
    }

    @objc
    private func checkForUpdates() {
        Task {
            let result = await reRuneCheckForUpdates()
            await MainActor.run {
                lastRedraw = Self.currentTimestamp()
                statusLabel.text = "Button check: \(statusText(for: result))"
                rebindStrings()
            }
        }
    }

    @objc
    private func pullToRefresh() {
        Task {
            let result = await reRuneCheckForUpdates()
            await MainActor.run {
                lastRedraw = Self.currentTimestamp()
                statusLabel.text = "Pull refresh: \(statusText(for: result))"
                refreshControl.endRefreshing()
                rebindStrings()
            }
        }
    }

    @objc
    private func applyProgrammaticTexts() {
        titleLabel.text = reRuneString("title")
        subtitleLabel.text = reRuneString("body")
        statusLabel.text = "Applied title/body programmatically"
    }

    private func layoutViews() {
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.numberOfLines = 0
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        placeholderLabel.font = .preferredFont(forTextStyle: .body)
        placeholderLabel.numberOfLines = 0
        redrawLabel.font = .preferredFont(forTextStyle: .footnote)
        redrawLabel.textColor = .secondaryLabel
        redrawLabel.numberOfLines = 0
        inputField.borderStyle = .roundedRect
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0

        checkButton.addTarget(self, action: #selector(checkForUpdates), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyProgrammaticTexts), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        [titleLabel, subtitleLabel, placeholderLabel, redrawLabel, inputField, checkButton, applyButton, statusLabel].forEach {
            stackView.addArrangedSubview($0)
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.refreshControl = refreshControl
        scrollView.addSubview(stackView)

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func formattedString(_ key: String, _ arguments: [CVarArg]) -> String {
        let format = reRuneString(key)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }

    private func statusText(for result: ReRuneUpdateResult) -> String {
        switch result.status {
        case .updated:
            return "Updated locales: \(result.updatedLocales.sorted().joined(separator: ", "))"
        case .noChange:
            return "No translation changes found"
        case .failed:
            return result.errorMessage ?? "Update failed"
        }
    }

    private static func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
