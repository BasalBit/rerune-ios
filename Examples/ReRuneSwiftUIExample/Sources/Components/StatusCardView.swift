import SwiftUI

struct StatusCardView: View {
    let rows: [(label: String, value: String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(row.label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(DemoTheme.textSecondary)

                    Spacer(minLength: 12)

                    Text(row.value)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(DemoTheme.textPrimary)
                }
                .padding(.vertical, 18)

                if index < rows.count - 1 {
                    Rectangle()
                        .fill(DemoTheme.borderSubtle)
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 20)
        .background(DemoTheme.bgSecondary.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: DemoTheme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DemoTheme.cardRadius, style: .continuous)
                .stroke(DemoTheme.borderSubtle, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.28), radius: 20, x: 0, y: 14)
    }
}
