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

## Runtime language picker

After setup, apps can show the union of compiled bundle locales and ReRune dashboard locales:

```swift
let locales = reRuneAvailableLocales
```

`reRuneAvailableLocalesPublisher` emits when a manifest fetch changes the remote locale list. To switch the SDK runtime language from an in-app picker:

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

The picker should render `reRuneAvailableLocales`; after a successful manifest fetch, that list can include dashboard-only locales that were not compiled into the app bundle.

## Plural strings

Dashboard plural updates use the same native lookup and formatting calls as bundled `.stringsdict` plurals:

```swift
let format = NSLocalizedString("item_count", comment: "")
let text = String.localizedStringWithFormat(format, count)
```

ReRune supports integer plural categories from direct `.xcstrings` `variations.plural` entries and standard plural substitutions. Malformed or unsupported entries fall back to the app's bundled localization.

Foundation chooses the plural category using the device's current formatting locale. When `reRuneSetLocale(_:)` selects a language whose plural rules differ from the device locale, ReRune selects that language's OTA text but Foundation still chooses its category using the device locale.

## Notes

- SDK installs a targeted `Bundle.main` localization override so UIKit and Foundation code can keep using native lookup APIs.
- API auth is `otaPublishId` only.
- Manifest endpoint is fixed by SDK to `platform=ios_xcstrings`.
- Manifest parsing is strict: root `version`, keyed `locales`, required root `main_language`, locale `version`, and optional locale `url`.
- `main_language` must normalize to a locale declared in the same manifest. Manifests without it are rejected; an invalid cached manifest and its locale bundles are purged during setup.
- Locale payloads must be `.xcstrings` catalog JSON.
- The default `Localizable` catalog supports simple strings plus integer plural entries; non-plural substitutions and other variation types remain unsupported.
- Dashboard-only locales appear in `reRuneAvailableLocales` after a successful manifest fetch, or on startup when a cached manifest already lists them.
- Runtime lookup uses the selected ReRune locale when set, otherwise the platform preferred language. Missing OTA keys then use the manifest `main_language` OTA chain before bundled strings.
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
