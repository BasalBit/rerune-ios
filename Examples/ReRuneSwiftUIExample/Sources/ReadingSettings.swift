import SwiftUI

struct ReadingSettings: View {
    @ObservedObject var store: ChapterStore
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    Text(store.text(.reading_settings)).font(ReadingFont.sans(28, bold: true, relativeTo: .title)).accessibilityAddTraits(.isHeader)
                    Spacer(minLength: 8)
                    Button { dismiss() } label: { Image(systemName: "xmark").frame(width: 48, height: 48) }
                        .accessibilityLabel(store.text(.back_library))
                }
                Text(store.text(.settings_description)).font(ReadingFont.sans(15)).foregroundColor(Color(ChapterStyle.secondary))
                Toggle(isOn: Binding(get: { store.variantSelected }, set: { selected in Task { await store.setVariant(selected) } })) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.text(.translation_variant)).font(ReadingFont.sans(17))
                        Text(store.variantSelected ? store.variantName : "Main").font(ReadingFont.sans(15))
                    }
                }.disabled(store.changingVariant || store.refreshState == .busy || store.changingStagingMode)
                    .tint(Color(ChapterStyle.accent))
                    .accessibilityIdentifier("variant")
                if store.changingVariant { ProgressView() }
                if store.variantFailed {
                    Text(store.text(.edition_change_error)).foregroundColor(.red).font(ReadingFont.sans(13))
                }
                Divider().background(Color(ChapterStyle.border))
                Toggle(isOn: Binding(get: { store.stagingModeActive }, set: { enabled in Task { await store.setStagingMode(enabled) } })) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.text(.staging_mode)).font(ReadingFont.sans(17))
                        Text(store.text(.staging_mode_description)).font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
                    }
                }.disabled(store.changingStagingMode || store.refreshState == .busy || store.changingVariant).tint(Color(ChapterStyle.accent))
                    .accessibilityIdentifier("staging-mode")
                if store.changingStagingMode { ProgressView() }
                if store.stagingModeFailed {
                    Text(store.text(.staging_mode_error)).foregroundColor(.red).font(ReadingFont.sans(13))
                }
                Divider().background(Color(ChapterStyle.border))
                VStack(alignment: .leading, spacing: 14) {
                    Text(store.text.publish_date(publish_date: "14.07.2026"))
                    Text(store.text.plural_sample(count: 1))
                    Text(store.text.plural_sample(count: 2))
                }.font(ReadingFont.sans(15)).foregroundColor(Color(ChapterStyle.secondary))
                RefreshTexts(store: store)
                Text(store.text(.session_note)).font(ReadingFont.sans(13)).foregroundColor(Color(ChapterStyle.secondary))
            }.frame(maxWidth: ChapterStyle.readerWidth).padding(24).frame(maxWidth: .infinity)
        }.background(Color(ChapterStyle.surface).ignoresSafeArea()).foregroundColor(Color(ChapterStyle.primary))
            .preferredColorScheme(.dark)
    }
}
