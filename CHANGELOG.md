# Changelog

## Unreleased

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
- Replaced iOS `ReRuneUpdatePolicy.periodicInterval` with Android-style `periodicIntervalInHours` and `periodicIntervalInDays` fields.
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
