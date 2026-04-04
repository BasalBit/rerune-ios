import UIKit

enum DemoTheme {
    static let bgPrimary = UIColor(red: 11.0 / 255.0, green: 15.0 / 255.0, blue: 23.0 / 255.0, alpha: 1.0)
    static let bgSecondary = UIColor(red: 18.0 / 255.0, green: 24.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
    static let bgTertiary = UIColor(red: 15.0 / 255.0, green: 21.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
    static let textPrimary = UIColor(red: 245.0 / 255.0, green: 247.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
    static let textSecondary = UIColor(red: 152.0 / 255.0, green: 162.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    static let accentPrimary = UIColor(red: 245.0 / 255.0, green: 166.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
    static let accentStrong = UIColor(red: 1.0, green: 181.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
    static let success = UIColor(red: 61.0 / 255.0, green: 220.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
    static let borderSubtle = UIColor.white.withAlphaComponent(0.08)

    static let cardRadius: CGFloat = 24
    static let buttonRadius: CGFloat = 20
    static let horizontalPadding: CGFloat = 24

    static func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFont(descriptor: base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor, size: size)
    }
}

final class DemoBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let amberGlow = UIView()
    private let navyGlow = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
        gradientLayer.colors = [
            DemoTheme.bgPrimary.cgColor,
            DemoTheme.bgSecondary.cgColor,
            DemoTheme.bgTertiary.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(gradientLayer)

        [amberGlow, navyGlow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }

        amberGlow.backgroundColor = DemoTheme.accentPrimary.withAlphaComponent(0.18)
        amberGlow.layer.shadowColor = DemoTheme.accentPrimary.withAlphaComponent(0.24).cgColor
        amberGlow.layer.shadowOpacity = 1
        amberGlow.layer.shadowRadius = 60

        navyGlow.backgroundColor = UIColor(red: 70.0 / 255.0, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 0.18)
        navyGlow.layer.shadowColor = UIColor(red: 70.0 / 255.0, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 0.22).cgColor
        navyGlow.layer.shadowOpacity = 1
        navyGlow.layer.shadowRadius = 72

        NSLayoutConstraint.activate([
            amberGlow.widthAnchor.constraint(equalToConstant: 240),
            amberGlow.heightAnchor.constraint(equalToConstant: 240),
            amberGlow.topAnchor.constraint(equalTo: topAnchor, constant: -80),
            amberGlow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 120),

            navyGlow.widthAnchor.constraint(equalToConstant: 280),
            navyGlow.heightAnchor.constraint(equalToConstant: 280),
            navyGlow.topAnchor.constraint(equalTo: topAnchor, constant: -40),
            navyGlow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -140),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        amberGlow.layer.cornerRadius = amberGlow.bounds.width / 2
        navyGlow.layer.cornerRadius = navyGlow.bounds.width / 2
    }
}

extension UIView {
    func pinEdges(to other: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor),
            leadingAnchor.constraint(equalTo: other.leadingAnchor),
            trailingAnchor.constraint(equalTo: other.trailingAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor),
        ])
    }
}

extension UILabel {
    static func demoLabel(font: UIFont, color: UIColor, lines: Int = 1) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = color
        label.numberOfLines = lines
        return label
    }
}

extension UIButton {
    static func demoPrimaryButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = nil
        button.contentEdgeInsets = UIEdgeInsets(top: 18, left: 24, bottom: 18, right: 24)
        button.setTitleColor(DemoTheme.bgPrimary, for: .normal)
        button.titleLabel?.font = DemoTheme.roundedFont(size: 17, weight: .bold)
        button.layer.cornerRadius = DemoTheme.buttonRadius
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.shadowColor = DemoTheme.accentPrimary.withAlphaComponent(0.3).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 18
        button.layer.shadowOffset = CGSize(width: 0, height: 12)

        let gradient = CAGradientLayer()
        gradient.colors = [DemoTheme.accentPrimary.cgColor, DemoTheme.accentStrong.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.name = "DemoPrimaryGradient"
        button.layer.insertSublayer(gradient, at: 0)

        return button
    }

    static func demoAccentButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = nil
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        button.setTitleColor(DemoTheme.bgPrimary, for: .normal)
        button.setTitleColor(DemoTheme.bgPrimary.withAlphaComponent(0.55), for: .disabled)
        button.titleLabel?.font = DemoTheme.roundedFont(size: 16, weight: .bold)
        button.backgroundColor = DemoTheme.accentPrimary
        button.layer.cornerRadius = DemoTheme.buttonRadius
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        return button
    }

    func updatePrimaryGradientFrame() {
        if let gradient = layer.sublayers?.first(where: { $0.name == "DemoPrimaryGradient" }) {
            gradient.frame = bounds
            gradient.cornerRadius = DemoTheme.buttonRadius
        }
    }
}
