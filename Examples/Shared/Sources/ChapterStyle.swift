import UIKit

enum ChapterStyle {
    static let background = color(0x0B1019)
    static let surface = color(0x161F2D)
    static let primary = color(0xF4F1EA)
    static let secondary = color(0xA5ADBA)
    static let prose = color(0xD5D5CF)
    static let accent = color(0xF4AE45)
    static let brightAccent = color(0xFFC36D)
    static let border = color(0x293241)
    static let gutter: CGFloat = 24
    static let radius: CGFloat = 22
    static let libraryWidth: CGFloat = 1040
    static let readerWidth: CGFloat = 720
    static let columnsAt: CGFloat = 760

    static func color(_ hex: UInt32) -> UIColor {
        UIColor(red: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255,
                blue: CGFloat(hex & 255) / 255, alpha: 1)
    }

    static func font(_ size: CGFloat, bold: Bool = false, serif: Bool = false,
                     style: UIFont.TextStyle = .body) -> UIFont {
        let name = serif ? "Lora-Regular" : (bold ? "InstrumentSans-Bold" : "InstrumentSans-Regular")
        guard let font = UIFont(name: name, size: size) else { preconditionFailure("Missing bundled font: \(name)") }
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }

    static func verifyFonts() {
        for name in ["InstrumentSans-Regular", "InstrumentSans-Bold", "Lora-Regular"] {
            precondition(UIFont(name: name, size: 16) != nil, "Font failed to register: \(name)")
        }
    }
}
