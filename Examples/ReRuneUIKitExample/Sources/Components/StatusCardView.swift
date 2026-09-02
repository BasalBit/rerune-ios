import UIKit

final class StatusCardView: UIView {
    struct Row {
        enum Accessory {
            case text
            case menu(UIMenu)
            case toggle(
                isOn: Bool,
                isEnabled: Bool,
                onChange: (Bool) -> Void
            )
        }

        let label: String
        let value: String
        let accessory: Accessory

        static func text(label: String, value: String) -> Row {
            Row(label: label, value: value, accessory: .text)
        }

        static func picker(label: String, value: String, menu: UIMenu) -> Row {
            Row(label: label, value: value, accessory: .menu(menu))
        }

        static func toggle(
            label: String,
            value: String,
            isOn: Bool,
            isEnabled: Bool,
            onChange: @escaping (Bool) -> Void
        ) -> Row {
            Row(
                label: label,
                value: value,
                accessory: .toggle(
                    isOn: isOn,
                    isEnabled: isEnabled,
                    onChange: onChange
                )
            )
        }
    }

    private let stackView = UIStackView()
    private var arrangedRows: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = DemoTheme.bgSecondary
        layer.cornerRadius = DemoTheme.cardRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = DemoTheme.borderSubtle.cgColor
        layer.shadowColor = UIColor.black.withAlphaComponent(0.28).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 14)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(rows: [(label: String, value: String)]) {
        update(rows: rows.map { Row.text(label: $0.label, value: $0.value) })
    }

    func update(rows: [Row]) {
        arrangedRows.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        arrangedRows.removeAll()

        for (index, row) in rows.enumerated() {
            let rowView = makeRow(row: row)
            stackView.addArrangedSubview(rowView)
            arrangedRows.append(rowView)

            if index < rows.count - 1 {
                let divider = UIView()
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.backgroundColor = DemoTheme.borderSubtle
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(divider)
                arrangedRows.append(divider)
            }
        }
    }

    private func makeRow(row: Row) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let labelView = UILabel.demoLabel(
            font: DemoTheme.roundedFont(size: 14, weight: .semibold),
            color: DemoTheme.textSecondary
        )
        labelView.text = row.label

        let valueView: UIView
        switch row.accessory {
        case .text:
            valueView = makeValueLabel(text: row.value)
        case let .menu(menu):
            valueView = makePickerButton(title: row.value, menu: menu)
        case let .toggle(isOn, isEnabled, onChange):
            valueView = makeToggleAccessory(
                value: row.value,
                isOn: isOn,
                isEnabled: isEnabled,
                onChange: onChange
            )
        }

        let stack = UIStackView(arrangedSubviews: [labelView, UIView(), valueView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 16

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18),
        ])

        return container
    }

    private func makeValueLabel(text: String) -> UILabel {
        let valueView = UILabel.demoLabel(
            font: DemoTheme.roundedFont(size: 15, weight: .semibold),
            color: DemoTheme.textPrimary
        )
        valueView.text = text
        valueView.textAlignment = .right
        return valueView
    }

    private func makePickerButton(title: String, menu: UIMenu) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = menu

        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: "chevron.up.chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = .zero
        button.configuration = configuration
        button.tintColor = DemoTheme.textPrimary
        button.titleLabel?.font = DemoTheme.roundedFont(size: 15, weight: .semibold)

        return button
    }

    private func makeToggleAccessory(
        value: String,
        isOn: Bool,
        isEnabled: Bool,
        onChange: @escaping (Bool) -> Void
    ) -> UIView {
        let valueView = makeValueLabel(text: value)
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = isOn
        toggle.isEnabled = isEnabled
        toggle.onTintColor = DemoTheme.accentPrimary
        toggle.accessibilityLabel = "Variant"
        toggle.accessibilityValue = value
        toggle.addAction(
            UIAction { action in
                guard let sender = action.sender as? UISwitch else {
                    return
                }
                onChange(sender.isOn)
            },
            for: .valueChanged
        )

        let stack = UIStackView(arrangedSubviews: [valueView, toggle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }
}
