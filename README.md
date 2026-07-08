# rerune-ios

Public Swift Package Manager repository for the ReRune iOS SDK.

## Requirements

- iOS 15+

## Install (SPM)

Current public release: `0.5.0`

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

After the first successful fetch, the app can select German with `reRuneSetLocale("de")`. On the next launch, `reRuneSetup(...)` restores the cached manifest and German strings before the UI is shown, so `NSLocalizedString(...)` calls can render German without a compiled `de.lproj`.

This runtime language expansion is app-level. iOS Settings language lists, App Store language metadata, native system strings, and new string keys still require an app release.

## Supported localization assets

ReRune `0.5.0` works with the native iOS localization system, whether your app's bundled strings come from classic localization files or modern String Catalogs.

- Classic `.strings`
- Classic `.stringsdict`
- Modern String Catalog `.xcstrings`

Xcode compiles those assets into the app's native localization resources, and ReRune intercepts native `Bundle.main` / Foundation lookups at runtime for OTA-managed values.

## Supported runtime lookups

Use the native lookup paths below for strings that should participate in OTA updates:

- `NSLocalizedString("key", comment: "")`
- `Bundle.main.localizedString(forKey: "key", value: nil, table: nil)`

This keeps UIKit and SwiftUI code on standard Apple localization APIs while allowing ReRune to refresh visible content after OTA updates.

## UIKit quick start

```swift
import ReRune

reRuneSetup(otaPublishId: "replace-with-ota-publish-id")

titleLabel.text = NSLocalizedString("title", comment: "")
subtitleLabel.text = Bundle.main.localizedString(forKey: "subtitle", value: nil, table: nil)

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
        VStack {
            Text(NSLocalizedString("title", comment: ""))
            Text(Bundle.main.localizedString(forKey: "subtitle", value: nil, table: nil))
        }
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

## Notes

- SDK installs a targeted `Bundle.main` localization override so UIKit and Foundation code can keep using native lookup APIs.
- API auth is `otaPublishId` only.
- Manifest endpoint is fixed by SDK to `platform=ios_xcstrings`.
- Manifest parsing is strict: root `version`, keyed `locales`, locale `version`, optional locale `url`.
- Bundled app localizations can originate from classic `.strings` / `.stringsdict` files or modern `.xcstrings` String Catalogs.
- OTA locale payloads are `.xcstrings` catalog JSON fetched from the `ios_xcstrings` endpoint and applied through the same native lookup path.
- Current OTA application is scoped to the default `Localizable` table and simple string entries from the catalog.
- Dashboard-only locales appear in `reRuneAvailableLocales` after a successful manifest fetch, or on startup when a cached manifest already lists them.
- Runtime lookup uses the selected ReRune locale when set, otherwise the system preferred language. Missing OTA keys fall back to the app default remote locale before bundled strings.
- `reRuneRevisionPublisher` is the change notification stream for visible UI refreshes; the emitted value is the latest applied manifest revision and may repeat when OTA payloads change under the same manifest revision.
- Native OTA override support is scoped to `Bundle.main` and the default `Localizable` table.
- SwiftUI `Text("key")`, `LocalizedStringKey`, and `LocalizedStringResource` are not part of the OTA interception path; resolve the string first with `NSLocalizedString(...)` or `Bundle.main.localizedString(...)`, then pass the result into `Text(...)`.
- Periodic refresh policy uses Android-style split fields: `periodicIntervalInHours` + `periodicIntervalInDays`.

## Example apps

Open `Examples/ReRuneExamples.xcworkspace` to try both demo apps:

- `ReRuneUIKitExample`
- `ReRuneSwiftUIExample`

Both examples use the same demo OTA publish id.

They mirror the welcome/story demo flows kept in the source repo examples while consuming the published `0.5.0` package instead of the local workspace package.

The examples intentionally demonstrate both supported lookup styles: `NSLocalizedString(...)` and `Bundle.main.localizedString(...)`.
