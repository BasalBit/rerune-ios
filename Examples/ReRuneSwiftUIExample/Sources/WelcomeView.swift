import SwiftUI
import ReRune

struct WelcomeView: View {
    @State private var refreshPhase: RefreshPhase = .idle
    @State private var lastSyncedText = Self.formattedTimestamp(for: Date())

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    DemoBackgroundView()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                BadgeChipView(title: reRuneString("welcome_badge"))

                                Text(reRuneString("welcome_title"))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(DemoTheme.textPrimary)

                                Text(reRuneString("welcome_subtitle"))
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(DemoTheme.textSecondary)
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DemoTheme.horizontalPadding)

                            Spacer(minLength: 0)

                            Image("writer_orb")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: heroHeight(for: proxy.size.height))
                                .clipped()

                            Spacer(minLength: 0)

                            VStack(alignment: .leading, spacing: 14) {
                                StatusCardView(
                                    rows: [
                                        (label: reRuneString("welcome_locale_label"), value: reRuneString("welcome_locale_value")),
                                        (label: reRuneString("welcome_last_synced_label"), value: lastSyncedText)
                                    ]
                                )

                                Text(reRuneString(refreshPhase.localizationKey))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(refreshPhase.tint)
                                    .animation(.easeInOut(duration: 0.2), value: refreshPhase)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DemoTheme.horizontalPadding)

                            NavigationLink(destination: StoryView()) {
                                Text(reRuneString("welcome_open_story_cta"))
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(DemoTheme.bgPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        LinearGradient(
                                            colors: [DemoTheme.accentPrimary, DemoTheme.accentStrong],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: DemoTheme.buttonRadius, style: .continuous))
                                    .shadow(color: DemoTheme.accentPrimary.opacity(0.3), radius: 18, x: 0, y: 12)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, DemoTheme.horizontalPadding)
                        }
                        .padding(.vertical, 28)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: max(0, proxy.size.height - proxy.safeAreaInsets.top - proxy.safeAreaInsets.bottom),
                            alignment: .top
                        )
                    }
                    .refreshable {
                        await runRefreshFlow()
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .tint(DemoTheme.accentPrimary)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func runRefreshFlow() async {
        await MainActor.run {
            refreshPhase = .checking
        }

        try? await Task.sleep(nanoseconds: 350_000_000)

        await MainActor.run {
            refreshPhase = .downloading
        }

        let result = await reRuneCheckForUpdates()

        await MainActor.run {
            refreshPhase = .applying
        }

        try? await Task.sleep(nanoseconds: 300_000_000)

        await MainActor.run {
            lastSyncedText = Self.formattedTimestamp(for: Date())
            refreshPhase = result.status == .updated ? .success : .idle
        }
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static func formattedTimestamp(for date: Date) -> String {
        timestampFormatter.string(from: date)
    }

    private func heroHeight(for availableHeight: CGFloat) -> CGFloat {
        min(max(availableHeight * 0.34, 300), 460)
    }
}

private enum RefreshPhase: Equatable {
    case idle
    case checking
    case downloading
    case applying
    case success

    var localizationKey: String {
        switch self {
        case .idle:
            return "welcome_refresh_state_idle"
        case .checking:
            return "welcome_refresh_state_checking"
        case .downloading:
            return "welcome_refresh_state_downloading"
        case .applying:
            return "welcome_refresh_state_applying"
        case .success:
            return "welcome_refresh_state_success"
        }
    }

    var tint: Color {
        switch self {
        case .success:
            return DemoTheme.success
        case .idle:
            return DemoTheme.textSecondary
        case .checking, .downloading, .applying:
            return DemoTheme.accentPrimary
        }
    }
}

enum DemoTheme {
    static let bgPrimary = Color(red: 11.0 / 255.0, green: 15.0 / 255.0, blue: 23.0 / 255.0)
    static let bgSecondary = Color(red: 18.0 / 255.0, green: 24.0 / 255.0, blue: 38.0 / 255.0)
    static let bgTertiary = Color(red: 15.0 / 255.0, green: 21.0 / 255.0, blue: 34.0 / 255.0)
    static let textPrimary = Color(red: 245.0 / 255.0, green: 247.0 / 255.0, blue: 251.0 / 255.0)
    static let textSecondary = Color(red: 152.0 / 255.0, green: 162.0 / 255.0, blue: 179.0 / 255.0)
    static let accentPrimary = Color(red: 245.0 / 255.0, green: 166.0 / 255.0, blue: 35.0 / 255.0)
    static let accentStrong = Color(red: 1.0, green: 181.0 / 255.0, blue: 46.0 / 255.0)
    static let success = Color(red: 61.0 / 255.0, green: 220.0 / 255.0, blue: 151.0 / 255.0)
    static let borderSubtle = Color.white.opacity(0.08)
    static let cardRadius: CGFloat = 24
    static let buttonRadius: CGFloat = 20
    static let horizontalPadding: CGFloat = 24
}

struct DemoBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DemoTheme.bgPrimary, DemoTheme.bgSecondary, DemoTheme.bgTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(DemoTheme.accentPrimary.opacity(0.18))
                .frame(width: 240, height: 240)
                .blur(radius: 70)
                .offset(x: 110, y: -260)

            Circle()
                .fill(Color(red: 70.0 / 255.0, green: 105.0 / 255.0, blue: 180.0 / 255.0).opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: -130, y: -220)
        }
        .ignoresSafeArea()
    }
}
