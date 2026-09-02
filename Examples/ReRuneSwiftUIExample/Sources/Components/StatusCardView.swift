import SwiftUI

struct StatusCardView: View {
    let rows: [(label: String, value: String)]
    var localePicker: LocalePickerRow? = nil
    var variantToggle: VariantToggleRow? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let localePicker {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(localePicker.label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(DemoTheme.textSecondary)

                    Spacer(minLength: 12)

                    Menu {
                        ForEach(localePicker.locales, id: \.self) { locale in
                            Button {
                                localePicker.onSelect(locale)
                            } label: {
                                if locale == localePicker.selectedLocale {
                                    Label(locale, systemImage: "checkmark")
                                } else {
                                    Text(locale)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(localePicker.selectedLocale)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(DemoTheme.textPrimary)
                    }
                }
                .padding(.vertical, 18)

                if variantToggle != nil || !rows.isEmpty {
                    Rectangle()
                        .fill(DemoTheme.borderSubtle)
                        .frame(height: 1)
                }
            }

            if let variantToggle {
                HStack(spacing: 16) {
                    Text(variantToggle.label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(DemoTheme.textSecondary)

                    Spacer(minLength: 12)

                    Text(variantToggle.value)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(DemoTheme.textPrimary)

                    Toggle(
                        "",
                        isOn: Binding(
                            get: { variantToggle.isOn },
                            set: variantToggle.onChange
                        )
                    )
                    .labelsHidden()
                    .tint(DemoTheme.accentPrimary)
                    .disabled(!variantToggle.isEnabled)
                    .accessibilityLabel(variantToggle.label)
                    .accessibilityValue(variantToggle.value)
                }
                .padding(.vertical, 18)

                if !rows.isEmpty {
                    Rectangle()
                        .fill(DemoTheme.borderSubtle)
                        .frame(height: 1)
                }
            }

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

struct LocalePickerRow {
    let label: String
    let selectedLocale: String
    let locales: [String]
    let onSelect: (String) -> Void
}

struct VariantToggleRow {
    let label: String
    let value: String
    let isOn: Bool
    let isEnabled: Bool
    let onChange: (Bool) -> Void
}
