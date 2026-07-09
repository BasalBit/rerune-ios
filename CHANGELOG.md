# Changelog

## Unreleased

## 0.6.1 - 2026-07-09

- Reintroduced the app-level runtime locale APIs `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so in-app pickers can switch to dashboard-only locales immediately.
- Updated the SwiftUI and UIKit examples so the locale picker sets the app language in-place, persists the demo selection, and refreshes visible strings without opening iOS Settings.
- Fixed the SwiftUI example picker so selecting a menu item immediately updates the selected locale state and rerenders the screen.
- Expanded the user-facing README and example docs with runtime language picker and selection persistence guidance.

## 0.6.0 - 2026-07-09

- Removed the SDK-owned locale override APIs `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so ReRune no longer duplicates platform language selection state.
- Kept dashboard manifest locales available through `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher`.
- Updated runtime lookup to follow the platform preferred language only, falling back to the app default remote locale and then bundled strings.
- Updated the SwiftUI and UIKit examples to present available locales in a native picker that opens iOS Settings instead of setting a ReRune-owned locale override.

## 0.5.1 - 2026-07-09

- Republished the public binary package metadata so the SwiftPM checksum matches the uploaded `ReRune.xcframework.zip` asset.
- Aligned the runtime language picker examples with the dashboard-delivered German locale scenario.
- No SDK runtime code changes from `0.5.0`.

## 0.5.0 - 2026-07-08

- Added runtime locale availability APIs so apps can present `compiled app locales + ReRune manifest locales` through `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher`.
- Added `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so an in-app picker can select a dashboard-only locale without requiring that locale to be compiled into the app bundle.
- Updated OTA lookup fallback to use the selected locale, or the system preferred locale when no override is selected, then fall back to the app default remote locale before bundled strings.
- Documented the remote-language expansion use case where an English-only app can render a dashboard-delivered German locale after the manifest and locale payload are fetched and cached.

## 0.4.0 - 2026-04-13

- Switched the fixed iOS OTA platform from `ios_localizable_strings` to `ios_xcstrings` and removed OTA compatibility with flat `.strings` locale payloads.
- Changed locale payload parsing to require `.xcstrings` catalog JSON, applying only simple `Localizable` key/value entries and skipping unsupported catalog features such as plurals, substitutions, and variations.
- Changed `reRuneCheckForUpdates()` to continue OTA fetches even when the calling SwiftUI refresh task is cancelled, and updated SwiftUI guidance/examples to observe revision changes at the screen level.

## 0.3.0 - 2026-04-09

- Switched the iOS SDK from explicit `reRuneString(...)` lookups to native-first `Bundle.main` interception for `Localizable.strings`, so UIKit and Foundation call sites can keep using `NSLocalizedString(...)` and `Bundle.localizedString(...)`.
- Removed the public cache customization surface and synchronous explicit lookup API from the public SDK so setup can restore cached OTA strings before returning.
- Updated tests, examples, and docs to treat `Bundle.main` / `NSLocalizedString(...)` as the primary integration path and to document the phase-1 SwiftUI `Text("key")` limitation.

## 0.2.2 - 2026-04-04

- Expanded the public binary repo README to include the same UIKit and SwiftUI integration quick starts as the source SDK README.
- Fixed XCFramework packaging so the released binary embeds the generated `Modules/ReRune.swiftmodule` metadata required for `import ReRune`, and made the packaging script fail fast when module files are missing.

## 0.2.1 - 2026-03-30

- Replaced the static `ReRune.*` namespace API with top-level `reRune*` entry points so the `ReRune` module can be distributed as a stable binary XCFramework.
- Lowered the customer SDK and example minimum iOS version to iOS 15 and moved the SwiftUI example back to iOS-15-compatible navigation APIs.
- Added `Examples/ReRuneExamples.xcworkspace` as the single entry point for both the UIKit and SwiftUI demo apps.
- Added release automation for the public binary package repo `BasalBit/rerune-ios`, including XCFramework packaging, public repo syncing, and compatibility guards for the iOS 15 floor.

## 0.2.0 - 2026-03-28

- Merged the SwiftUI helper into the main SDK and renamed the Swift package product/module from `ReRuneCore` / `ReRuneSwiftUI` to a single `ReRune` import.
- Switched the fixed iOS OTA codec from `platform=ios` to `platform=ios_localizable_strings` and aligned fallback locale requests with `/sdk/translations/ios_localizable_strings/{locale}`.
- Tightened manifest parsing to the live iOS OTA contract: root `version`, keyed `locales`, locale `version`, and optional locale `url`.
- Removed legacy JSON locale payload compatibility; locale payloads must now be Apple `.strings` text.
- Renamed `ReRuneCachedLocaleBundle.payloadJson` to `payload`.
- Raised the iOS minimum version to iOS 16 and updated the SwiftUI example to use `NavigationStack`.
- Delivered `reRuneRevisionPublisher` updates on the main thread so UIKit observers can safely refresh UI when OTA content changes.
- Added `docs/sdk-maintenance-overview.md` with the current iOS module, runtime, backend, cache, and testing notes for maintainers.
- Added `AGENTS.md` and documented that this repository intentionally keeps maintainer history in `iOS_SPECS.md` and `CHANGELOG.md` instead of `docs/sessions/`.
- Replaced iOS `ReRuneUpdatePolicy.periodicInterval` with split `periodicIntervalInHours` and `periodicIntervalInDays` fields.
- Updated iOS OTA refresh behavior so manifest `304` responses reuse the cached manifest and still revalidate locale payloads with cached ETags.
- Softened locale-level update failures to preserve cached values and return `noChange` unless the manifest step itself fails.
- Clarified revision semantics so `reRuneRevision` tracks the latest applied manifest revision while `reRuneRevisionPublisher` remains the UI update notification stream.
- Added tests for cached-manifest revalidation, soft locale failures, locale fallback behavior, timeout handling, and repeated SwiftUI refresh notifications.

## 0.1.0

- Added initial iOS SDK implementation as Swift Package Manager modules: `ReRuneCore` and `ReRuneSwiftUI`.
- Added minimal public API centered on `reRuneSetup(...)`, `reRuneCheckForUpdates()`, `reRuneRevision`, and `reRuneString(...)`.
- Added OTA manifest and locale update flow with `X-OTA-Publish-Id`, fixed manifest endpoint, ETag support, cache-first startup, and fallback to bundled strings.
- Added UIKit and SwiftUI example app sources using live OTA endpoint configuration.
- Added unit tests for update flow, fallback behavior, and revision propagation.
