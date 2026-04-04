import UIKit

final class StatusCardView: UIView {
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
        arrangedRows.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        arrangedRows.removeAll()

        for (index, row) in rows.enumerated() {
            let rowView = makeRow(label: row.label, value: row.value)
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

    private func makeRow(label: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let labelView = UILabel.demoLabel(
            font: DemoTheme.roundedFont(size: 14, weight: .semibold),
            color: DemoTheme.textSecondary
        )
        labelView.text = label

        let valueView = UILabel.demoLabel(
            font: DemoTheme.roundedFont(size: 15, weight: .semibold),
            color: DemoTheme.textPrimary
        )
        valueView.text = value
        valueView.textAlignment = .right

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
}
