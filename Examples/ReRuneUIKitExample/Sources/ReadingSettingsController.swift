import UIKit

final class ReadingSettingsController: ChapterController {
    private let variant = UISwitch()
    private let variantName = ChapterViews.label()
    private let error = ChapterViews.label(13, color: .systemRed)
    private let spinner = UIActivityIndicatorView(style: .medium)
    override var maximumWidth: CGFloat { ChapterStyle.readerWidth }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChapterStyle.surface
        let title = text(.reading_settings, size: 28, bold: true); title.accessibilityTraits.insert(.header)
        let close = ChapterViews.button(symbol: "xmark") { [weak self] in self?.dismiss(animated: !UIAccessibility.isReduceMotionEnabled) }
        close.widthAnchor.constraint(equalToConstant: 48).isActive = true
        bind { [weak store, weak close] in close?.accessibilityLabel = store?.text(.back_library) }
        content.addArrangedSubview(ChapterViews.stack([title, close], spacing: 8, horizontal: true))
        content.addArrangedSubview(text(.settings_description, color: ChapterStyle.secondary))
        let edition = text(.translation_variant, size: 17)
        variant.onTintColor = ChapterStyle.accent; variant.accessibilityIdentifier = "variant"
        variant.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let selected = self.variant.isOn
            self.variant.setOn(self.store.variantSelected, animated: false)
            Task { await self.store.setVariant(selected) }
        }, for: .valueChanged)
        let row = ChapterViews.stack([ChapterViews.stack([edition, variantName], spacing: 6), variant], horizontal: true)
        row.alignment = .center
        content.addArrangedSubview(row); content.addArrangedSubview(spinner); content.addArrangedSubview(error)
        let line = UIView(); line.backgroundColor = ChapterStyle.border; line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        content.addArrangedSubview(line)
        let date = ChapterViews.label(color: ChapterStyle.secondary), one = ChapterViews.label(color: ChapterStyle.secondary), two = ChapterViews.label(color: ChapterStyle.secondary)
        bind { [weak store, weak date, weak one, weak two] in
            guard let store else { return }
            date?.text = store.text.publish_date(publish_date: "14.07.2026")
            one?.text = store.text.plural_sample(count: 1); two?.text = store.text.plural_sample(count: 2)
        }
        content.addArrangedSubview(ChapterViews.stack([date, one, two], spacing: 14))
        content.addArrangedSubview(RefreshPanel(store: store)); content.addArrangedSubview(text(.session_note, size: 13, color: ChapterStyle.secondary))
        rebind()
    }
    override func rebind() {
        super.rebind()
        variant.setOn(store.variantSelected, animated: false)
        variant.isEnabled = !store.changingVariant && store.refreshState != .busy
        variant.accessibilityLabel = store.text(.translation_variant)
        variantName.text = store.variantSelected ? store.variantName : "Main"
        error.isHidden = !store.variantFailed; error.text = store.text(.edition_change_error)
        spinner.isHidden = !store.changingVariant
        if store.changingVariant { spinner.startAnimating() } else { spinner.stopAnimating() }
    }
}
