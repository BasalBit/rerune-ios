import SwiftUI

struct BadgeChipView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(DemoTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [DemoTheme.accentPrimary.opacity(0.18), Color(red: 72.0 / 255.0, green: 94.0 / 255.0, blue: 160.0 / 255.0).opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(DemoTheme.borderSubtle, lineWidth: 1)
            }
    }
}
