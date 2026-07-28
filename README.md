# rerune-ios

Public Swift Package Manager repository for the ReRune iOS SDK.

## Requirements

- iOS 15+

## Install (SPM)

Add this package dependency in Xcode:

```text
https://github.com/BasalBit/rerune-ios.git
```

Then import:

```swift
import ReRune
```

## License

ReRune is available under the [MIT License](LICENSE).

## Remote languages without an app release

ReRune can make dashboard-only languages available even when the app bundle shipped with only English resources. For example, if the app has only `en` bundled strings and the ReRune dashboard later publishes German (`de`), the SDK fetches the German manifest entry and locale payload in the background, caches it, and exposes `de` through `reRuneAvailableLocales`.

When German is selected with `reRuneSetLocale("de")`, or when German is the user's platform-preferred language, `NSLocalizedString(...)` calls can render the dashboard-delivered German strings after the first successful fetch. On the next launch, `reRuneSetup(...)` restores the cached manifest and German strings before the UI is shown, so the same language can render immediately without a compiled `de.lproj`.

When the requested OTA locale does not contain a key, ReRune next checks the manifest's `main_language` OTA locale before falling back to the app's bundled Foundation localization. The backend owns this fallback; applications do not need another setup parameter. Cached manifests restore the same fallback synchronously on later launches.

This runtime language expansion is app-level. iOS Settings language lists, App Store language metadata, native system strings, and new string keys still require an app release.

## UIKit quick start

```swift
import ReRune

reRuneSetup(otaPublishId: "replace-with-ota-publish-id")

titleLabel.text = NSLocalizedString("title", comment: "")

reRuneRevisionPublisher
    .dropFirst()
    .sink { [weak self] _ in self?.rebindStrings() }
    .store(in: &cancellables)
```

## SwiftUI quick start

```swift
import SwiftUI
import ReRune

@main
struct ExampleApp: App {
    init() {
        reRuneSetup(otaPublishId: "replace-with-ota-publish-id")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(NSLocalizedString("title", comment: ""))
            .reRuneObserveRevision()
    }
}
```

## Logging

SDK diagnostics are disabled by default. Opt in during setup only when needed:

```swift
reRuneSetup(
    otaPublishId: "replace-with-ota-publish-id",
    logLevel: .info
)
```

| Level | Behavior |
| --- | --- |
| `.off` | Default. Emits no SDK diagnostics. |
| `.error` | High-level failures only, without causes or sensitive request/response details. |
| `.info` | Adds operation names, sanitized request method/URL, synchronization decisions, and response status codes. |
| `.verbose` | Adds full request URLs, headers, bodies, failure causes, and stack traces. |

Levels are cumulative and every message starts with `ReRune:`. Use `.verbose` only as an explicit sensitive-data diagnostic mode: it may expose the OTA publish ID, credentials, and translation content. Headers, bodies, credentials, causes, and stack traces are never logged below `.verbose`.

## Runtime language picker

After setup, apps can show the union of compiled bundle locales and ReRune dashboard locales:

```swift
let locales = reRuneAvailableLocales
let localeDetails = reRuneAvailableLocaleDetails
```

`reRuneAvailableLocalesPublisher` emits identifier-list changes.
`reRuneAvailableLocaleDetailsPublisher` also emits manifest display-name
changes. To switch the SDK runtime language from an in-app picker:

```swift
reRuneSetLocale("de")
```

Pass `nil` to follow the system preferred language again:

```swift
reRuneSetLocale(nil)
```

The current app-level override is available as `reRuneSelectedLocale`. Persist picker choices in app storage and reapply them after `reRuneSetup(...)` if the selected language should survive app restarts.

For example:

```swift
private let localeStorageKey = "selectedLocale"

func configureLocalization() {
    reRuneSetup(otaPublishId: "replace-with-ota-publish-id")
    reRuneSetLocale(UserDefaults.standard.string(forKey: localeStorageKey))
}

func selectLocale(_ locale: String?) {
    UserDefaults.standard.set(locale, forKey: localeStorageKey)
    reRuneSetLocale(locale)
}
```

The picker can render `reRuneAvailableLocaleDetails`; each `ReRuneLocale`
contains an `identifier` and nullable manifest-provided `name`. Compiled-only
locales use their identifier as the name. The existing
`reRuneAvailableLocales` API remains available when only identifiers are needed.

```swift
ForEach(reRuneAvailableLocaleDetails, id: \.identifier) { locale in
    Text(locale.name ?? locale.identifier)
}
```

After a dashboard-only locale is successfully applied, both lists can include
it even when it was not compiled into the app bundle.

## Plural strings

Dashboard plural updates use the same native lookup and formatting calls as bundled `.stringsdict` plurals:

```swift
let format = NSLocalizedString("item_count", comment: "")
let text = String.localizedStringWithFormat(format, count)
```

ReRune derives native cardinal plurals from the backend's generic structured
message records. The plural-control value remains the first native formatting
argument; displayed placeholders follow it as independent arguments.

For example, a message controlled by `count` that displays `firstName` and
`itemCount` keeps the normal Foundation call:

```swift
let format = NSLocalizedString("inventory_summary", comment: "")
let text = String.localizedStringWithFormat(
    format,
    count,
    firstName,
    itemCount
)
```

Malformed or unsupported rendering records reject that locale update and keep
the previously applied or bundled localization.

Foundation chooses the plural category using the device's current formatting locale. When `reRuneSetLocale(_:)` selects a language whose plural rules differ from the device locale, ReRune selects that language's OTA text but Foundation still chooses its category using the device locale.

## Notes

- SDK installs a targeted `Bundle.main` localization override so UIKit and Foundation code can keep using native lookup APIs.
- API auth is `otaPublishId` only.
- Manifest endpoint is fixed by SDK and has no platform query parameter.
- Manifest parsing is strict: root and locale `version` values are non-negative JSON integers; `locales` is keyed; `main_language` is required; and every locale has an absolute `url`.
- Manifest locale keys and `main_language` must use `language[-Script][-REGION]`, where language is 2–3 ASCII letters, script is 4 ASCII letters, and region is either 2 ASCII letters or 3 digits. `_` separators and surrounding whitespace are normalized.
- Every manifest locale requires a non-negative `minimum_delta_base_version`. Exact version/minimum matches skip that locale. A missing cache record or minimum change requests a full replacement with `target_version`; otherwise changed versions request a delta with the stored successful `version` and the manifest `target_version`.
- Locale `409` responses and manifests whose locale target is behind the stored successful version are treated as stale-manifest signals. ReRune retries the complete synchronization once after fetching the manifest without `If-None-Match`, then returns `.failed` if the refreshed state is still stale.
- ETag revalidation applies only to the manifest. Locale requests never send `If-None-Match`, and a locale `304` is treated as an unsupported per-locale failure that preserves cached state.
- `main_language` must normalize to a locale declared in the same manifest. Manifests without it are rejected; an invalid cached manifest and its locale bundles are purged during setup.
- Each locale URL returns a top-level array of locale-scoped generic translation
  records. Every record has a `values` array containing zero or one entry.
  `values: []` is preserved in cache but supplies no runtime override, so lookup
  continues through the main-language and bundled fallback chain. Plain
  `value` messages and structured cardinal plurals are supported when one entry
  is present.
- A delta record with `values: []` replaces the cached record and removes any
  previous runtime override for that key. Records omitted from a delta retain
  their cached state. A one-entry record with `value: ""` remains an intentional
  empty translation and does not fall back.
- Placeholder tokens use `{{name}}`. Names are case-sensitive; `string` and
  `int` declaration types are case-insensitive; multiple placeholders are
  supported.
- A visible token without an exact matching declaration makes only that plain
  or plural key unavailable remotely. ReRune still caches the complete record
  and continues through the normal locale, main-language, and bundled fallback
  chain. In a delta, that replacement also removes any previous override.
- Other malformed declarations, token syntax, or rendering structures still
  reject the locale atomically. Unknown non-rendering fields are preserved and
  ignored at runtime.
- Dashboard-only locales appear in `reRuneAvailableLocales` only after their locale payload and manifest metadata are successfully committed, or on startup when a valid applied-locale cache record restores them.
- Each successful locale commit stores the manifest entry's `name`, `url`, `version`, and `minimum_delta_base_version` with a complete canonical generic JSON snapshot. A failed locale retains its previous applied metadata; the cached raw manifest remains only the transport snapshot used for later retries.
- This breaking cache schema uses a new namespace. Legacy platform-specific
  cache entries are not read, migrated, or deleted, so the first launch after
  upgrading behaves like a cold OTA cache.
- `reRuneAvailableLocaleDetails` and `reRuneAvailableLocaleDetailsPublisher` expose normalized locale identifiers plus nullable successfully applied manifest names. Equal-version name-only changes are persisted without calling the locale endpoint and publish the manifest revision.
- Runtime lookup uses the selected ReRune locale when set, otherwise the platform preferred language. Missing OTA keys then use the manifest `main_language` OTA chain before bundled strings.
- `reRuneSetup(...)` restores and parses the local cache synchronously so cached strings are immediately available. Its startup network check runs in a detached Swift-concurrency task and does not delay setup completion.
- `reRuneRevisionPublisher` is the change notification stream for visible UI refreshes; the emitted value is the latest applied manifest revision and may repeat when OTA payloads change under the same manifest revision.
- Native OTA override support in phase 1 is limited to `Bundle.main` and the default `Localizable` table.
- SwiftUI `Text("key")`, `LocalizedStringKey`, and `LocalizedStringResource` are not supported for OTA interception in phase 1; use `NSLocalizedString(...)` inside SwiftUI views instead.
- Periodic refresh policy uses split fields: `periodicIntervalInHours` + `periodicIntervalInDays`.

## Example apps

Open `Examples/ReRuneExamples.xcworkspace` to try both demo apps:

- `ReRuneUIKitExample`
- `ReRuneSwiftUIExample`

Both examples use the same demo OTA publish id.

They mirror the welcome/story demo flows kept in the source repo examples while consuming the published package instead of the local workspace package.
