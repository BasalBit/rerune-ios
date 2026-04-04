import UIKit

final class BadgeChipView: UIView {
    private let label = UILabel.demoLabel(
        font: DemoTheme.roundedFont(size: 13, weight: .semibold),
        color: DemoTheme.textPrimary
    )
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = 1
        layer.borderColor = DemoTheme.borderSubtle.cgColor
        gradientLayer.colors = [
            DemoTheme.accentPrimary.withAlphaComponent(0.18).cgColor,
            UIColor(red: 72.0 / 255.0, green: 94.0 / 255.0, blue: 160.0 / 255.0, alpha: 0.2).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.height / 2
    }

    func update(title: String) {
        label.text = title
    }
}
