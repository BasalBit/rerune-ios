import SwiftUI
import ReRune

struct ContentView: View {
    @State private var resultMessage = ""
    @State private var sampleInput = ""
    @State private var lastRedraw = Self.currentTimestamp()

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(reRuneString("title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(reRuneString("body"))
                        .foregroundStyle(.secondary)

                    Text(formattedString("sample_placeholder", [1, "RubinTXT"]))

                    Text(formattedString("last_redraw", [lastRedraw]))
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    TextField(reRuneString("input_hint"), text: $sampleInput)
                        .accessibilityLabel(reRuneString("input_content_description"))
                }

                Section {
                    Button(reRuneString("button")) {
                        Task {
                            await runUpdateCheck(source: "Button check")
                        }
                    }
                    .accessibilityLabel(reRuneString("check_updates_content_description"))

                    if !resultMessage.isEmpty {
                        Text(resultMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("ReRune")
            .refreshable {
                await runUpdateCheck(source: "Pull refresh")
            }
        }
    }

    private func runUpdateCheck(source: String) async {
        let result = await reRuneCheckForUpdates()
        lastRedraw = Self.currentTimestamp()
        resultMessage = "\(source): \(statusText(for: result))"
    }

    private func formattedString(_ key: String, _ arguments: [CVarArg]) -> String {
        let format = reRuneString(key)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }

    private func statusText(for result: ReRuneUpdateResult) -> String {
        switch result.status {
        case .updated:
            return "Updated locales: \(result.updatedLocales.sorted().joined(separator: ", "))"
        case .noChange:
            return "No translation changes found"
        case .failed:
            return result.errorMessage ?? "Update failed"
        }
    }

    private static func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
