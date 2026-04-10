import SwiftUI
import ReRune

struct StoryView: View {
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            DemoBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Image("blacksmith")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(DemoTheme.borderSubtle, lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(localized("story_title"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(DemoTheme.textPrimary)

                        Text(localized("story_body_primary"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(DemoTheme.textPrimary)
                            .lineSpacing(4)

                        Text(localized("story_body_secondary"))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(DemoTheme.textSecondary)
                            .lineSpacing(4)

                        BadgeChipView(title: localized("story_caption"))
                    }

                    Button(action: runRefresh) {
                        HStack(spacing: 8) {
                            if isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(DemoTheme.bgPrimary)
                            }

                            Text(localized("story_refresh_cta"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(DemoTheme.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DemoTheme.accentPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: DemoTheme.buttonRadius, style: .continuous))
                    }
                    .disabled(isRefreshing)
                }
                .padding(.horizontal, DemoTheme.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .tint(DemoTheme.accentPrimary)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func runRefresh() {
        guard !isRefreshing else { return }

        Task {
            isRefreshing = true
            _ = await reRuneCheckForUpdates()
            isRefreshing = false
        }
    }

    private func localized(_ key: String) -> String {
        if key == "welcome_title" || key == "story_title" {
            return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        }

        return NSLocalizedString(key, comment: "")
    }
}
