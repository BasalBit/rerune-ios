import CoreGraphics

enum CoverArtwork {
    static func draw(_ id: StoryID, in context: CGContext, size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        context.saveGState()
        context.scaleBy(x: size.width / 600, y: size.height / 400)
        let aspect = (size.width / size.height) / 1.5
        switch id {
        case .atlas: atlas(context, aspect)
        case .lantern: lantern(context, aspect)
        case .garden: garden(context, aspect)
        }
        context.restoreGState()
    }

    private static func color(_ rgb: UInt32, alpha: CGFloat = 1) -> CGColor {
        CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [
            CGFloat((rgb >> 16) & 255) / 255, CGFloat((rgb >> 8) & 255) / 255,
            CGFloat(rgb & 255) / 255, alpha
        ])!
    }
    private static func fill(_ c: CGContext, _ rgb: UInt32) {
        c.setFillColor(color(rgb)); c.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
    }
    private static func circle(_ c: CGContext, _ x: CGFloat, _ y: CGFloat, _ radius: CGFloat,
                               _ rgb: UInt32, _ aspect: CGFloat) {
        c.setFillColor(color(rgb))
        c.fillEllipse(in: CGRect(x: x - radius / aspect, y: y - radius, width: radius * 2 / aspect, height: radius * 2))
    }
    private static func path(_ c: CGContext, _ rgb: UInt32, _ draw: (CGMutablePath) -> Void) {
        let p = CGMutablePath(); draw(p); p.closeSubpath()
        c.addPath(p); c.setFillColor(color(rgb)); c.fillPath()
    }
    private static func atlas(_ c: CGContext, _ aspect: CGFloat) {
        fill(c, 0xD5DCC6)
        c.setStrokeColor(color(0x708B79, alpha: 0.23)); c.setLineWidth(1.3)
        for i in 0..<15 {
            let r = CGFloat(94 + i * 13)
            c.strokeEllipse(in: CGRect(x: 484 - r / aspect, y: 345 - r, width: r * 2 / aspect, height: r * 2))
        }
        circle(c, 457, 157, 39, 0xD58C4E, aspect)
        path(c, 0x547D79) { p in
            p.move(to: CGPoint(x: 0, y: 290))
            p.addCurve(to: CGPoint(x: 348, y: 278), control1: CGPoint(x: 140, y: 340), control2: CGPoint(x: 207, y: 345))
            p.addCurve(to: CGPoint(x: 600, y: 267), control1: CGPoint(x: 440, y: 231), control2: CGPoint(x: 500, y: 254))
            p.addLine(to: CGPoint(x: 600, y: 400)); p.addLine(to: CGPoint(x: 0, y: 400))
        }
        path(c, 0x244E52) { p in
            p.move(to: CGPoint(x: 0, y: 341))
            p.addCurve(to: CGPoint(x: 600, y: 319), control1: CGPoint(x: 166, y: 379), control2: CGPoint(x: 304, y: 265))
            p.addLine(to: CGPoint(x: 600, y: 400)); p.addLine(to: CGPoint(x: 0, y: 400))
        }
        path(c, 0x163A41) { p in
            p.move(to: CGPoint(x: 0, y: 386))
            p.addCurve(to: CGPoint(x: 600, y: 354), control1: CGPoint(x: 163, y: 315), control2: CGPoint(x: 321, y: 397))
            p.addLine(to: CGPoint(x: 600, y: 400)); p.addLine(to: CGPoint(x: 0, y: 400))
        }
    }
    private static func lantern(_ c: CGContext, _ aspect: CGFloat) {
        fill(c, 0x243E59)
        for i in 0..<28 { circle(c, CGFloat((i * 97 + 37) % 600), CGFloat((i * 43 + 27) % 260), i % 3 == 0 ? 2 : 1, 0xB4CBC9, aspect) }
        circle(c, 463, 113, 41, 0xF0D6A0, aspect); circle(c, 449, 102, 37, 0x243E59, aspect)
        path(c, 0x3B5A69) { p in
            p.move(to: CGPoint(x: 0, y: 319))
            for point in [(141,147),(311,339),(463,206),(600,328),(600,400),(0,400)] {
                p.addLine(to: CGPoint(x: point.0, y: point.1))
            }
        }
        path(c, 0x182C42) { p in
            p.move(to: CGPoint(x: 0, y: 368))
            for point in [(207,222),(361,373),(505,285),(600,355),(600,400),(0,400)] {
                p.addLine(to: CGPoint(x: point.0, y: point.1))
            }
        }
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: [color(0xF4B35A, alpha: 0.6), color(0xF4B35A, alpha: 0)] as CFArray,
                                     locations: [0, 1]) {
            c.drawRadialGradient(gradient, startCenter: CGPoint(x: 316, y: 316), startRadius: 0,
                                 endCenter: CGPoint(x: 316, y: 316), endRadius: 50, options: [])
        }
        c.setFillColor(color(0xF4BE69))
        c.addPath(CGPath(roundedRect: CGRect(x: 307, y: 299, width: 18, height: 30), cornerWidth: 4, cornerHeight: 4, transform: nil)); c.fillPath()
        c.setStrokeColor(color(0xF4BE69)); c.setLineWidth(2)
        c.addArc(center: CGPoint(x: 316, y: 299), radius: 8, startAngle: .pi, endAngle: 2 * .pi, clockwise: false); c.strokePath()
    }
    private static func garden(_ c: CGContext, _ aspect: CGFloat) {
        fill(c, 0xE8CBAC); circle(c, 468, 128, 69, 0xD99D7E, aspect)
        path(c, 0x698475) { p in
            p.move(to: CGPoint(x: 0, y: 325)); p.addQuadCurve(to: CGPoint(x: 600, y: 318), control: CGPoint(x: 277, y: 244))
            p.addLine(to: CGPoint(x: 600, y: 400)); p.addLine(to: CGPoint(x: 0, y: 400))
        }
        for i in 0..<6 {
            let x = CGFloat(70 + i * 99), y = CGFloat(240 + (i % 3) * 37)
            let stem = CGMutablePath(); stem.move(to: CGPoint(x: x, y: 410))
            stem.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: x - 18, y: y + 50))
            c.addPath(stem); c.setStrokeColor(color(0x34584E)); c.setLineWidth(3); c.strokePath()
            for j in 0..<3 {
                let leafY = y + 35 + CGFloat(j * 33)
                c.setFillColor(color(0x34584E)); c.fillEllipse(in: CGRect(x: x - 34.5, y: leafY - 7, width: 35, height: 14))
                c.setFillColor(color(0x43695A)); c.fillEllipse(in: CGRect(x: x - 3, y: leafY + 8.5, width: 30, height: 13))
            }
            circle(c, x, y, 11, 0xF2DFB6, aspect); circle(c, x, y, 4, 0xBB7456, aspect)
        }
    }
}
