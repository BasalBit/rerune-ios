# Changelog

## Unreleased

## 1.2.0 (2026-09-21)

### SDK consumer changes

- Added opt-in staging preview through the `staging:` argument on
  `reRuneSetup(...)`. It defaults to `false` and applies only to the current
  setup session.
- Added `reRuneSetStagingMode(_:)` for switching modes and synchronizing
  immediately after setup. Added `reRuneIsStagingModeEnabled` for reading the
  active mode. Calling the setter before setup throws
  `ReRuneStagingModeError.setupRequired`.
- Staging synchronization now applies complete locale snapshots, so draft
  additions, edits, deletions, disabled values, and never-published keys are
  reflected on the next successful sync.
- Staging and production state are isolated. A mode change restores the
  selected mode's cached content, and results from superseded update checks are
  discarded instead of crossing between modes.

## 1.1.1 (2026-09-14)

### SDK consumer changes

- Fixed locale payloads that use zero-based placeholder positions. These
  payloads previously caused the affected locale to be rejected. Existing
  positive Foundation positions retain their meaning.

## 1.1.0 (2026-09-02)

### SDK consumer changes

- Added translation variants through `ReRuneVariant`, the `variant:` argument
  on `reRuneSetup(...)`, `reRuneSetVariant(_:)`, and `reRuneResetVariant()`.
  Variant selection persists for each project, while `.main` selects the main
  translation.
- Added main-translation fallback for missing variant values. Variant strings
  continue through the existing placeholder and plural formatting behavior.
- Fixed text-only structured messages so literal percent signs remain
  unchanged.
- Added the MIT license to the downloadable XCFramework archive.

## 1.0.0 (2026-08-05)

### SDK consumer changes

- Declared the SDK contract stable with the first `1.x` release.
- No SDK runtime or public API changes from `0.13.1`.

## 0.13.1 (2026-07-29)

### SDK consumer changes

- Maintenance release with no SDK runtime or public API changes from `0.13.0`.
- The XCFramework retains the public Swift module interface required by
  consuming apps and no longer includes private symbol metadata.

## 0.13.0 (2026-07-28)

### SDK consumer changes

- Restored the MIT license for the SDK and binary package. Version `0.12.0`
  retains the proprietary license included in that release.
- No SDK runtime or public API changes from `0.12.0`.

## 0.12.0 (2026-07-28)

### SDK consumer changes

- Changed this release to BasalBit GmbH's proprietary commercial license.
  Earlier releases retain the licenses included with their tags.
- No SDK runtime or public API changes from `0.11.0`.

## 0.11.0 (2026-07-27)

### SDK consumer changes

- Breaking: replaced String Catalog payload transport with locale-scoped JSON
  records. Apps continue using native `NSLocalizedString`, `String(format:_:)`,
  and `String.localizedStringWithFormat` call sites.
- Breaking: each manifest locale now requires an absolute `url`. The previous
  `platform=ios_xcstrings` request and hardcoded locale endpoint are no longer
  used.
- Added named `{{placeholder}}` tokens and structured cardinal plurals with a
  separate control argument. A placeholder mismatch falls back only for the
  affected key instead of rejecting the full locale.
- Added untranslated records. An empty `values` array removes an earlier OTA
  override, while an empty string remains an intentional translation.
- Breaking: moved persistence to the `ReRuneGenericV1` cache namespace. Older
  platform-specific caches are not migrated and must be downloaded again.

## 0.10.0 (2026-07-24)

### SDK consumer changes

- Breaking: locale synchronization now uses stored `version` and requested
  `target_version` values instead of RFC 3339 `updated_at` cursors.
- Added automatic recovery when a locale rejects a stale manifest. The SDK
  refreshes the manifest once before reporting a terminal failure.
- Added optional locale display names through `ReRuneLocale`,
  `reRuneAvailableLocaleDetails`, and
  `reRuneAvailableLocaleDetailsPublisher`. Compiled-only locales use their
  identifier as the display-name fallback.

## 0.9.0 (2026-07-21)

### SDK consumer changes

- Breaking: replaced the previous logging levels with cumulative `off`,
  `error`, `info`, and `verbose` levels. Logging now defaults to `off`.
- Added consistently prefixed network and synchronization diagnostics.
  Sensitive request details are emitted only when `verbose` logging is
  explicitly enabled.

## 0.8.0 (2026-07-21)

### SDK consumer changes

- Added incremental per-locale String Catalog updates. Unchanged locale
  versions are skipped, while changed locales receive atomic delta merges.
- Removed cached data for locales that are no longer published in the
  manifest.
- Breaking: locale identifiers must use the
  `language[-Script][-REGION]` form, and manifest versions must be
  non-negative JSON integers.
- Breaking: cache records from earlier SDK versions are incompatible and are
  replaced by a fresh locale download.
- Cache restoration remains synchronous for immediate startup lookups, while
  startup and periodic network synchronization run without blocking
  `reRuneSetup(...)`.

## 0.7.0 (2026-07-16)

### SDK consumer changes

- Added OTA missing-key fallback through the manifest's required
  `main_language` value.
- Added dashboard-delivered cardinal plurals for direct `variations.plural`
  entries and standard String Catalog substitutions. Existing
  `NSLocalizedString(...)` and `String.localizedStringWithFormat(...)` call
  sites continue to work.
- Breaking: manifests without a valid `main_language` are rejected. Invalid
  cached manifests and their locale data are cleared during setup.
- Plural category selection follows the device formatting locale. A runtime
  locale override with different plural rules may therefore select unexpected
  categories.

## 0.6.1 (2026-07-09)

### SDK consumer changes

- Reintroduced `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so in-app
  language pickers can switch immediately to dashboard-delivered locales.

## 0.6.0 (2026-07-09)

### SDK consumer changes

- Breaking: removed `reRuneSetLocale(_:)` and `reRuneSelectedLocale`. Runtime
  lookup follows the platform preferred language, then the app's default
  remote locale, then bundled strings.
- `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher` remain
  available for presenting supported languages.

## 0.5.1 (2026-07-09)

### SDK consumer changes

- Fixed the Swift Package Manager checksum so the published
  `ReRune.xcframework.zip` installs successfully.
- No SDK runtime changes from `0.5.0`.

## 0.5.0 (2026-07-08)

### SDK consumer changes

- Added `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher` so apps
  can present compiled and dashboard-delivered languages together.
- Added `reRuneSetLocale(_:)` and `reRuneSelectedLocale` for selecting a
  dashboard-only language from an in-app picker.
- OTA lookup uses the selected locale, or the system preferred locale when no
  override is active, before falling back to the app's default remote locale
  and bundled strings.

## 0.4.0 (2026-04-13)

### SDK consumer changes

- Breaking: switched OTA payloads from flat `.strings` content to String
  Catalog JSON through the `ios_xcstrings` platform. This release supports
  simple `Localizable` key and value entries only.
- `reRuneCheckForUpdates()` now continues an in-flight OTA fetch if the calling
  SwiftUI refresh task is cancelled.

## 0.3.0 (2026-04-09)

### SDK consumer changes

- Breaking: replaced explicit `reRuneString(...)` lookups with native
  `Bundle.main` interception for `Localizable.strings`. Existing
  `NSLocalizedString(...)` and `Bundle.localizedString(...)` call sites can
  receive OTA values.
- Removed the public cache-store types. `reRuneSetup(...)` restores cached OTA
  strings before returning.
- SwiftUI `Text("key")` does not use the intercepted lookup path in this
  release.

## 0.2.2 (2026-04-04)

### SDK consumer changes

- Fixed the XCFramework so it includes the Swift module metadata required for
  `import ReRune`.
- Added UIKit and SwiftUI integration quick starts to the public package.

## 0.2.1 (2026-03-30)

### SDK consumer changes

- Breaking: replaced the static `ReRune.*` namespace with top-level
  `reRune*` functions and values.
- Lowered the minimum supported iOS version from 16 to 15.

## 0.2.0 (2026-03-28)

### SDK consumer changes

- Breaking: merged `ReRuneCore` and `ReRuneSwiftUI` into a single `ReRune`
  module and package product.
- Breaking: changed OTA locale payloads to Apple `.strings` text through the
  `ios_localizable_strings` platform. Legacy JSON locale payloads are no
  longer accepted.
- Breaking: raised the minimum iOS version to 16 and split
  `ReRuneUpdatePolicy.periodicInterval` into hour and day interval fields.
- Delivered `reRuneRevisionPublisher` updates on the main thread so UIKit
  observers can refresh UI safely.
- Locale update failures preserve cached values. A cached manifest can still
  revalidate locale payloads after a `304` response.

## 0.1.0

### SDK consumer changes

- Initial Swift Package Manager release with `ReRuneCore` and
  `ReRuneSwiftUI` modules.
- Added `reRuneSetup(...)`, `reRuneCheckForUpdates()`, `reRuneRevision`, and
  `reRuneString(...)`.
- Added cache-first OTA manifest and locale updates with bundled-string
  fallback.
