# Changelog

## Unreleased

## 1.1.0 (2026-09-02)

- Added the root MIT `LICENSE` to future XCFramework ZIPs and release checks
  that reject a missing or altered license notice.
- Added SDK-side translation variant selection with a type-safe `.main`
  sentinel, setup configuration, asynchronous runtime changes, persisted
  project-scoped selection, and `reRuneResetVariant()`.
- Named the consumer-facing concept Variant through `ReRuneVariant`, the
  `variant:` setup argument, `reRuneSetVariant`, and `reRuneResetVariant` while
  preserving the server's Variation wire-field names.
- Preserved the original `reRuneSetup` overload for compiled consumers while
  adding a variant-aware overload whose selection defaults to `.main`.
- Added exact-slug main fallback across hierarchical locale payloads. Selected
  plain and structured variant content continues through the existing
  placeholder and native plural pipeline, including nested message parts.
- Fixed text-only structured messages so literal percent signs remain unchanged.
  Structured messages that require Foundation formatting still escape them.
- Added a configurable Main or Variant toggle to both example welcome screens
  for manual selection testing. Main and Variant selections persist across app
  relaunches. Both welcome hero images also show the `publish_date` placeholder
  with a fixed date on a transparent overlay.

## 1.0.0 (2026-08-05)

- Refreshed the public Swift package landing page with an outcome-oriented
  introduction, a dashboard-to-app delivery summary, and ReRune-branded social
  preview artwork derived from the live website visual language.
- Updated release synchronization so public package visual assets are retained
  across future binary SDK releases.
- Added a guarded manual publishing command and maintainer protocol that check
  release versioning, changelog preparation, synchronized Git state, GitHub
  release infrastructure, exact-commit compatibility results, operator
  attestations, public artifact checksums, and private debug-symbol retention.
- Added release-workflow validation that rejects malformed or unprepared source
  tags before building a customer XCFramework.
- Extended publishing guards and release automation to support stable semantic
  versions. Stable breaking changes require a major version bump.
- Declared the current SDK contract stable as version `1.0.0`.
- No SDK runtime or public API changes.

## 0.13.1 (2026-07-29)

- Removed dSYMs, ABI JSON, and private/package Swift interface variants from
  the public XCFramework while retaining the public module interface required
  by consumers.
- Added release-time checks that reject maintainer-only metadata and absolute
  local build paths in the public binary artifact.
- Retained device and simulator dSYMs in private source-repository release
  storage for crash symbolication instead of publishing them to consumers.
- Improved the public package description and search-oriented README metadata.
- No SDK runtime or public API changes from `0.13.0`.

## 0.13.0 (2026-07-28)

- Restored the MIT License for the current SDK and public binary package.
- Restored the historical `0.2.1` through `0.11.0` public tags and binary
  releases under the MIT licenses included in those tags. Version `0.12.0`
  retains the proprietary license included in its tagged release.
- Upgraded repository checkout and GitHub release automation to their Node
  24-compatible action versions. This changes release infrastructure only; the
  SDK runtime and public API are unchanged.
- No SDK runtime or public API changes from `0.12.0`.

## 0.12.0 (2026-07-28)

- Changed this release from the MIT License to BasalBit GmbH's proprietary
  commercial license. Previously published versions retain the license files
  included in their tagged releases.
- No SDK runtime or public API changes from `0.11.0`.

## 0.11.0 (2026-07-27)

- Breaking: replaced the iOS String Catalog transport with locale-scoped,
  platform-agnostic JSON records while preserving native
  `NSLocalizedString`, `String(format:_:)`, and
  `String.localizedStringWithFormat` call sites.
- Breaking: removed the manifest `platform=ios_xcstrings` query and the
  hardcoded `ios_xcstrings/{locale}` fallback. Every manifest locale now
  requires an absolute `url`.
- Added strict locale-atomic validation for plain messages, named
  `{{placeholder}}` tokens, case-insensitive `string`/`int` declaration types,
  and structured cardinal plurals with an independent control argument.
- Changed delta persistence to replace complete generic records by key while
  preserving omitted records and unknown non-rendering fields. Full responses
  remain authoritative complete snapshots.
- Added untranslated locale records: `values: []` is preserved in canonical
  cache state without creating a runtime override. In deltas it replaces the
  cached record and removes an earlier override, while `value: ""` remains an
  intentional empty translation.
- Changed placeholder token/declaration name mismatches to fail only that plain
  or plural key's runtime projection. The complete backend record is cached,
  deltas remove any earlier override for the key, and normal localization
  fallback continues; other structural validation remains locale-atomic.
- Breaking: moved locale persistence to the new `ReRuneGenericV1` cache
  namespace, requires the applied locale URL in each cache record, and does not
  read, migrate, or delete legacy platform-specific cache entries.
- Deferred a public custom cache-store API and literal double-brace escaping;
  both remain internal/backend contract follow-up work.

## 0.10.0 (2026-07-24)

- Breaking: replaced RFC 3339 `updated_at` locale cursors with version-targeted requests. Full requests send `target_version`; delta requests send the last successfully stored locale `version` plus `target_version`; equal locale versions still skip the request.
- Added stale-manifest recovery: locale `409` responses and manifest targets below a stored successful locale version restart synchronization once with an unconditional manifest fetch, then return a terminal failure if the refreshed manifest is still stale.
- Removed `updatedAtCursor` from locale cache records. Existing records may contain the obsolete extra JSON key, but it is ignored and never affects requests.
- Added nullable manifest locale names through `ReRuneLocale`, `reRuneAvailableLocaleDetails`, and `reRuneAvailableLocaleDetailsPublisher`. Compiled-only locales use their identifier as the fallback name, and name-only manifest changes publish a revision.
- Locale cache records now persist the manifest entry's nullable `name` and optional `url` with its version, minimum delta base, and payload. New or changed locale metadata becomes applied/public only after the locale record commits successfully; failures retain the previous applied metadata.
- Enabled verbose SDK logging in both iOS example apps.

## 0.9.0 (2026-07-21)

- Breaking: replaced the previous `none`/`warning`/`debug` logging levels with the cumulative `off`, `error`, `info`, and `verbose` contract; SDK logging now defaults to `off`.
- Added consistently prefixed request, response, synchronization-decision, and failure diagnostics. Headers, credentials, bodies, failure causes, full request URLs, and stack traces are emitted only through the explicit `verbose` sensitive-data opt-in.

## 0.8.0 (2026-07-21)

- Added per-locale incremental `.xcstrings` updates through persisted RFC 3339 `updated_at` cursors.
- Added atomic whole-entry batch merging into the complete cached locale catalog, including cursor-safe failure handling and no-op batch suppression.
- Breaking: locale requests and cache records no longer use ETags; manifest ETag revalidation remains unchanged.
- Breaking: locale cache records now require an `updatedAtCursor`; records written by earlier SDK versions are rejected and must be repopulated from a fresh full locale response.
- Breaking: every manifest locale now requires `minimum_delta_base_version`, and every locale cache record requires `minimumDeltaBaseVersion`; a changed per-locale minimum forces a cursorless full fetch and complete cache replacement.
- Accepted `minimum_delta_base_version` values greater than or equal to zero while retaining exact-equality synchronization checks.
- Breaking: locale cache records now require the last successfully applied manifest locale `version`; matching versions skip locale requests, while changed versions remain eligible for retry until a valid response is applied.
- Added runtime and disk-cache cleanup for locales removed from the manifest.
- Fixed `304` handling so an uncached manifest response fails explicitly and an unexpected locale response reports a specific error without advancing locale synchronization state.
- Fixed cache commit handling so manifest write failures stop synchronization without changing manifest state, while locale write failures preserve that locale's runtime and synchronization state and do not stop remaining locales.
- Fixed locale no-change detection to compare parsed runtime translations, so unsupported catalog data, irrelevant localizations, and entry metadata changes still advance synchronization state without publishing a visible update.
- Breaking: root and per-locale manifest versions must now be non-negative JSON integers. Applied locale versions are persisted as integers, and locale cache records containing string or otherwise invalid versions are rejected.
- Made unpublished-locale disk cleanup explicitly best-effort: listing and deletion failures are logged without failing synchronization, while cleanup is retried during later bootstrap and manifest application.
- Breaking: SDK-controlled locale identifiers must now use the common `language[-Script][-REGION]` subset. Malformed identifiers, variants, extensions, private-use tags, non-ASCII components, and unsafe path characters are rejected.
- Kept cache restoration synchronous for immediate startup lookup while explicitly detaching startup and periodic network synchronization so `reRuneSetup(...)` never waits for network completion.

## 0.7.0 (2026-07-16)

- Added server-owned OTA missing-key fallback through the manifest's required `main_language`, including cached-startup restoration, canonical locale matching, and revision publication when fallback metadata or loaded-locale removal changes visible lookup.
- Changed the manifest contract incompatibly: manifests without `main_language` are rejected, and an invalid cached manifest plus its associated locale bundles and ETags are purged during setup.
- Added dashboard-delivered plural overrides for `.xcstrings` payloads while preserving native `NSLocalizedString(...)` plus `String.localizedStringWithFormat(...)` call sites.
- Added support for direct `variations.plural` entries and standard plural `substitutions`, with cache bootstrap, locale fallback, ETag revalidation, and revision publication for plural-only updates.
- Added native `.stringsdict` plural fallbacks and visible plural examples to both private example apps.
- Documented that native Foundation plural category selection follows the device formatting locale; a `reRuneSetLocale(_:)` override that uses materially different plural rules may not select that locale's categories.
- Kept private example-app OTA configuration out of the public binary repository during release synchronization.

## 0.6.1 (2026-07-09)

- Reintroduced the app-level runtime locale APIs `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so in-app pickers can switch to dashboard-only locales immediately.
- Updated the SwiftUI and UIKit examples so the locale picker sets the app language in-place, persists the demo selection, and refreshes visible strings without opening iOS Settings.
- Fixed the SwiftUI example picker so selecting a menu item immediately updates the selected locale state and rerenders the screen.
- Expanded the user-facing README and example docs with runtime language picker and selection persistence guidance.

## 0.6.0 (2026-07-09)

- Removed the SDK-owned locale override APIs `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so ReRune no longer duplicates platform language selection state.
- Kept dashboard manifest locales available through `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher`.
- Updated runtime lookup to follow the platform preferred language only, falling back to the app default remote locale and then bundled strings.
- Updated the SwiftUI and UIKit examples to present available locales in a native picker that opens iOS Settings instead of setting a ReRune-owned locale override.

## 0.5.1 (2026-07-09)

- Republished the public binary package metadata so the SwiftPM checksum matches the uploaded `ReRune.xcframework.zip` asset.
- Aligned the runtime language picker examples with the dashboard-delivered German locale scenario.
- No SDK runtime code changes from `0.5.0`.

## 0.5.0 (2026-07-08)

- Added runtime locale availability APIs so apps can present `compiled app locales + ReRune manifest locales` through `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher`.
- Added `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so an in-app picker can select a dashboard-only locale without requiring that locale to be compiled into the app bundle.
- Updated OTA lookup fallback to use the selected locale, or the system preferred locale when no override is selected, then fall back to the app default remote locale before bundled strings.
- Documented the remote-language expansion use case where an English-only app can render a dashboard-delivered German locale after the manifest and locale payload are fetched and cached.

## 0.4.0 (2026-04-13)

- Switched the fixed iOS OTA platform from `ios_localizable_strings` to `ios_xcstrings` and removed OTA compatibility with flat `.strings` locale payloads.
- Changed locale payload parsing to require `.xcstrings` catalog JSON, applying only simple `Localizable` key/value entries and skipping unsupported catalog features such as plurals, substitutions, and variations.
- Changed `reRuneCheckForUpdates()` to continue OTA fetches even when the calling SwiftUI refresh task is cancelled, and updated SwiftUI guidance/examples to observe revision changes at the screen level.

## 0.3.0 (2026-04-09)

- Switched the iOS SDK from explicit `reRuneString(...)` lookups to native-first `Bundle.main` interception for `Localizable.strings`, so UIKit and Foundation call sites can keep using `NSLocalizedString(...)` and `Bundle.localizedString(...)`.
- Removed the public cache customization surface and synchronous explicit lookup API from the public SDK so setup can restore cached OTA strings before returning.
- Updated tests, examples, and docs to treat `Bundle.main` / `NSLocalizedString(...)` as the primary integration path and to document the phase-1 SwiftUI `Text("key")` limitation.

## 0.2.2 (2026-04-04)

- Expanded the public binary repo README to include the same UIKit and SwiftUI integration quick starts as the source SDK README.
- Fixed XCFramework packaging so the released binary embeds the generated `Modules/ReRune.swiftmodule` metadata required for `import ReRune`, and made the packaging script fail fast when module files are missing.

## 0.2.1 (2026-03-30)

- Replaced the static `ReRune.*` namespace API with top-level `reRune*` entry points so the `ReRune` module can be distributed as a stable binary XCFramework.
- Lowered the customer SDK and example minimum iOS version to iOS 15 and moved the SwiftUI example back to iOS-15-compatible navigation APIs.
- Added `Examples/ReRuneExamples.xcworkspace` as the single entry point for both the UIKit and SwiftUI demo apps.
- Added release automation for the public binary package repo `BasalBit/rerune-ios`, including XCFramework packaging, public repo syncing, and compatibility guards for the iOS 15 floor.

## 0.2.0 (2026-03-28)

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
