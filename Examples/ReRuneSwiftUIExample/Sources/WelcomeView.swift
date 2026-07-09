import Foundation
import SwiftUI
import ReRune

struct WelcomeView: View {
    @State private var refreshPhase: RefreshPhase = .idle
    @State private var lastSyncedText = Self.formattedTimestamp(for: Date())
    @State private var selectedLocaleCode = Self.resolvedLocaleCode()

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    DemoBackgroundView()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                BadgeChipView(title: localized("welcome_badge"))

                                Text(localized("welcome_title"))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(DemoTheme.textPrimary)

                                Text(localized("welcome_subtitle"))
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
                                        (label: localized("welcome_last_synced_label"), value: lastSyncedText)
                                    ],
                                    localePicker: LocalePickerRow(
                                        label: localized("welcome_locale_label"),
                                        selectedLocale: selectedLocaleCode,
                                        locales: availableLocaleCodes,
                                        onSelect: selectLocale
                                    )
                                )

                                Text(localized(refreshPhase.localizationKey))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(refreshPhase.tint)
                                    .animation(.easeInOut(duration: 0.2), value: refreshPhase)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DemoTheme.horizontalPadding)

                            NavigationLink(destination: StoryView()) {
                                Text(localized("welcome_open_story_cta"))
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
        .reRuneObserveRevision()
        .onReceive(reRuneRevisionPublisher) { _ in
            syncSelectedLocaleCode()
        }
        .onReceive(reRuneAvailableLocalesPublisher) { _ in
            syncSelectedLocaleCode()
        }
    }

    private func runRefreshFlow() async {
        await MainActor.run {
            refreshPhase = .checking
        }

        await MainActor.run {
            refreshPhase = .downloading
        }

        let result = await reRuneCheckForUpdates()

        await MainActor.run {
            refreshPhase = .applying
        }

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

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private var availableLocaleCodes: [String] {
        Self.availableLocaleCodes(selectedLocale: selectedLocaleCode)
    }

    private func selectLocale(_ locale: String) {
        let normalizedLocale = Self.normalizedLocaleOrNil(locale) ?? locale
        selectedLocaleCode = normalizedLocale
        UserDefaults.standard.set(normalizedLocale, forKey: "rerune.example.selectedLocale")
        reRuneSetLocale(normalizedLocale)
    }

    private func syncSelectedLocaleCode() {
        selectedLocaleCode = Self.resolvedLocaleCode()
    }

    private static func resolvedLocaleCode() -> String {
        let availableLocales = Set(reRuneAvailableLocales.compactMap(normalizedLocaleOrNil))
        let preferredLocale = reRuneSelectedLocale ?? Locale.preferredLanguages.first ?? appDefaultLocale()
        var candidates = localeChain(from: preferredLocale)

        for fallback in localeChain(from: appDefaultLocale()) where !candidates.contains(fallback) {
            candidates.append(fallback)
        }

        return candidates.first(where: { availableLocales.contains($0) }) ?? candidates.first ?? appDefaultLocale()
    }

    private static func availableLocaleCodes(selectedLocale: String) -> [String] {
        var locales = Set(reRuneAvailableLocales.compactMap(normalizedLocaleOrNil))
        locales.insert(selectedLocale)
        return locales.sorted()
    }

    private static func localeChain(from localeTag: String) -> [String] {
        let normalized = normalize(localeTag)
        let parts = normalized.split(separator: "-").map(String.init)
        guard !parts.isEmpty else { return [appDefaultLocale()] }

        return stride(from: parts.count, through: 1, by: -1).map { index in
            parts.prefix(index).joined(separator: "-")
        }
    }

    private static func appDefaultLocale() -> String {
        if
            let developmentRegion = Bundle.main.object(forInfoDictionaryKey: "CFBundleDevelopmentRegion") as? String,
            let normalized = normalizedLocaleOrNil(developmentRegion)
        {
            return normalized
        }

        return "en"
    }

    private static func normalizedLocaleOrNil(_ localeTag: String) -> String? {
        let normalized = normalize(localeTag)
        guard !normalized.isEmpty, normalized != "Base" else {
            return nil
        }

        return normalized
    }

    private static func normalize(_ localeTag: String) -> String {
        localeTag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "-")
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
